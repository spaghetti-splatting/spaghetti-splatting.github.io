/*
 * Fly-through compare players.
 *
 * A two-half MP4 holds two equal halves side by side. The left half is the render.
 * The right half is the Blender clay of the same frame, from the same camera.
 * The player draws the render left of the split and the clay right of the split.
 * A single-stream MP4 holds one stream. Its player draws the whole frame, with no split.
 */
(function () {
  'use strict';

  // ---------------------------------------------------------------------------
  // Scene table. Edit this object to change the datasets and the scenes.
  // The video of a scene is VIDEO_ROOT/<dataset>/<scene id>.mp4.
  // The key of each entry is the data-flythrough value of a section in index.html.
  // A section has one, two, or three players. Two or three players stand side by side.
  // The first player is the leader. The other players follow the clock of the leader.
  // Set single: true for a player with a single-stream video. That player draws the
  // whole frame, with no split and no corner labels.
  // ---------------------------------------------------------------------------
  const VIDEO_ROOT = 'videos';

  const FLYTHROUGHS = {
    mipnerf360: {
      players: [{ dataset: 'mipnerf360' }],
      scenes: [
        { id: 'bicycle', label: 'Bicycle' },
        { id: 'flowers', label: 'Flowers' },
        { id: 'garden', label: 'Garden' },
        { id: 'stump', label: 'Stump' },
        { id: 'treehill', label: 'Treehill' },
        { id: 'room', label: 'Room' },
        { id: 'counter', label: 'Counter' },
        { id: 'kitchen', label: 'Kitchen' },
        { id: 'bonsai', label: 'Bonsai' },
      ],
    },
    shelly: {
      players: [{ dataset: 'shelly' }],
      scenes: [
        { id: 'fernvase', label: 'Fernvase' },
        { id: 'horse', label: 'Horse' },
        { id: 'khady', label: 'Khady' },
        { id: 'kitten', label: 'Kitten' },
        { id: 'pug', label: 'Pug' },
        { id: 'woolly', label: 'Woolly' },
      ],
    },
    fuzzy: {
      players: [{ dataset: 'fuzzy' }],
      scenes: [
        { id: 'cactus1', label: 'Cactus 1' },
        { id: 'cactus2', label: 'Cactus 2' },
        { id: 'dinosaur', label: 'Dinosaur' },
        { id: 'flowers', label: 'Flowers' },
        { id: 'fur', label: 'Fur' },
        { id: 'kiwi', label: 'Kiwi' },
        { id: 'tawashi', label: 'Tawashi' },
        { id: 'textiles', label: 'Textiles' },
      ],
    },
    hair: {
      players: [
        { dataset: 'hair_gt', title: 'Ground truth strands', single: true },
        { dataset: 'hair_gh', title: 'Gaussian Haircut' },
        { dataset: 'hair_ours', title: 'Ours, Gaussian' },
      ],
      scenes: [
        { id: '381', label: '381', tooltip: 'chin-length bob, straight' },
        { id: '310', label: '310', tooltip: 'short, straight, fringe' },
        { id: '319', label: '319', tooltip: 'short, straight, swept up' },
        { id: '261', label: '261', tooltip: 'short, curly' },
        { id: '380', label: '380', tooltip: 'shoulder-length, straight' },
        { id: '107', label: '107', tooltip: 'long, straight' },
        { id: '108', label: '108', tooltip: 'long, wavy, voluminous' },
        { id: '147', label: '147', tooltip: 'long, half-up' },
        { id: 'curly', label: 'Curly' },
      ],
    },
  };

  // A follower seeks to the leader time when the drift is more than this value, in seconds.
  // The value is one frame at 60 fps.
  const MAX_DRIFT = 1 / 60;
  const HAVE_CURRENT_DATA = 2;
  const HAS_FRAME_CALLBACK = 'requestVideoFrameCallback' in HTMLVideoElement.prototype;

  function element(tag, className, text) {
    const node = document.createElement(tag);
    node.className = className;
    if (text) node.textContent = text;
    return node;
  }

  // The browser can refuse playback. The player then shows the first frame.
  function playQuietly(video) {
    const promise = video.play();
    if (promise) promise.catch(function () {});
  }

  // Seek a video to time 0. The promise resolves when the seek ends or when the video cannot load.
  function seekToStart(video) {
    return new Promise((resolve) => {
      if (video.error) {
        resolve();
        return;
      }
      const finish = () => {
        video.removeEventListener('loadedmetadata', seek);
        video.removeEventListener('seeked', seeked);
        video.removeEventListener('error', finish);
        resolve();
      };
      // A 'seeked' event of an older seek can arrive while this seek runs. Ignore that event.
      const seeked = () => {
        if (!video.seeking) finish();
      };
      const seek = () => {
        video.removeEventListener('loadedmetadata', seek);
        video.addEventListener('seeked', seeked);
        video.currentTime = 0;
      };
      video.addEventListener('error', finish);
      // A video without metadata (readyState 0) cannot seek. Seek when the metadata arrives.
      if (video.readyState === 0) video.addEventListener('loadedmetadata', seek);
      else seek();
    });
  }

  // One canvas that shows one video: the render left of the split, the clay right of it.
  // In single-stream mode, the canvas shows the whole frame of the video.
  class ComparePlayer {
    constructor(parent, title, single) {
      this.single = Boolean(single); // True for a single-stream video.
      this.split = 0.5; // Split position as a fraction of the canvas width.
      this.scale = 1; // Canvas pixels per CSS pixel.
      this.frameRequest = null; // Handle of the pending requestVideoFrameCallback.
      this.loopRequest = null; // Handle of the requestAnimationFrame loop (fallback).
      this.redrawRequest = null; // Handle of a pending redraw after a split change.
      this.onVideoFrame = null; // Function that runs after each new video frame.

      const figure = element('figure', this.single ? 'player player-single-stream' : 'player');
      if (title) figure.appendChild(element('figcaption', 'player-title', title));

      this.stage = element('div', 'player-stage');
      this.video = element('video', 'player-video');
      this.canvas = element('canvas', 'player-canvas');
      this.ctx = this.canvas.getContext('2d');
      this.loading = element('div', 'player-loading', 'Loading…');

      const video = this.video;
      video.muted = true;
      video.defaultMuted = true;
      video.loop = true;
      video.playsInline = true;
      video.autoplay = true;
      video.preload = 'auto';
      video.setAttribute('aria-hidden', 'true');

      // A single-stream player has no corner labels.
      const labels = this.single ? [] : [
        element('span', 'player-label player-label-left', 'Render'),
        element('span', 'player-label player-label-right', 'Clay primitives'),
      ];
      this.stage.append(video, this.canvas, ...labels, this.loading);
      figure.appendChild(this.stage);
      parent.appendChild(figure);

      video.addEventListener('loadedmetadata', () => this.resize());
      video.addEventListener('loadeddata', () => this.draw());
      video.addEventListener('seeked', () => this.draw());
      if (!HAS_FRAME_CALLBACK) video.addEventListener('play', () => this.startLoop());
      new ResizeObserver(() => this.resize()).observe(this.stage);

      // The split follows the mouse over the canvas and a touch drag on phones.
      // The split stays in its position when the pointer leaves the canvas.
      // A single-stream player has no split, so it does not follow the pointer.
      if (this.single) return;
      const follow = (event) => {
        const rect = this.canvas.getBoundingClientRect();
        if (rect.width > 0) {
          this.split = Math.min(1, Math.max(0, (event.clientX - rect.left) / rect.width));
          this.requestRedraw();
        }
      };
      this.canvas.addEventListener('pointermove', follow);
      this.canvas.addEventListener('pointerdown', (event) => {
        if (event.pointerType !== 'mouse') this.canvas.setPointerCapture(event.pointerId);
        follow(event);
      });
    }

    // Load a scene. The split position does not change.
    setSource(url) {
      if (this.frameRequest !== null) {
        this.video.cancelVideoFrameCallback(this.frameRequest);
        this.frameRequest = null;
      }
      this.ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);
      this.loading.hidden = false;
      this.video.src = url;
      this.watchFrames();
    }

    // Give the stage the aspect ratio of one video half. In single-stream mode, use the whole frame.
    // Give the canvas one pixel per device pixel.
    resize() {
      const video = this.video;
      if (video.videoWidth > 0 && video.videoHeight > 0) {
        const frameWidth = this.single ? video.videoWidth : video.videoWidth / 2;
        this.stage.style.aspectRatio = frameWidth + ' / ' + video.videoHeight;
      }
      const rect = this.stage.getBoundingClientRect();
      this.scale = window.devicePixelRatio || 1;
      const width = Math.max(1, Math.round(rect.width * this.scale));
      const height = Math.max(1, Math.round(rect.height * this.scale));
      if (this.canvas.width !== width || this.canvas.height !== height) {
        this.canvas.width = width;
        this.canvas.height = height;
        this.draw();
      }
    }

    // Draw the current video frame. A two-half player also draws the split line.
    draw() {
      const video = this.video;
      if (video.readyState < HAVE_CURRENT_DATA || video.videoWidth === 0) return;
      const ctx = this.ctx;
      const width = this.canvas.width;
      const height = this.canvas.height;
      ctx.imageSmoothingQuality = 'high';
      // Single-stream mode: the whole frame on the whole canvas, with no split line.
      if (this.single) {
        ctx.drawImage(video, 0, 0, width, height);
        if (!this.loading.hidden) this.loading.hidden = true;
        return;
      }
      const half = video.videoWidth / 2;
      const x = Math.round(this.split * width);
      // Left of the split: the same columns of the left half (render).
      if (x > 0) {
        ctx.drawImage(video, 0, 0, (half * x) / width, video.videoHeight, 0, 0, x, height);
      }
      // Right of the split: the same columns of the right half (clay).
      if (x < width) {
        ctx.drawImage(video, half + (half * x) / width, 0, (half * (width - x)) / width, video.videoHeight,
          x, 0, width - x, height);
      }
      // Split line: 1 CSS pixel of white with a faint dark shadow.
      const lineWidth = Math.max(1, Math.round(this.scale));
      ctx.save();
      ctx.shadowColor = 'rgba(0, 0, 0, 0.5)';
      ctx.shadowBlur = 3 * this.scale;
      ctx.fillStyle = '#fff';
      ctx.fillRect(x - Math.floor(lineWidth / 2), 0, lineWidth, height);
      ctx.restore();
      if (!this.loading.hidden) this.loading.hidden = true;
    }

    // Redraw one time in the next animation frame after a split change.
    requestRedraw() {
      if (this.redrawRequest !== null) return;
      this.redrawRequest = requestAnimationFrame(() => {
        this.redrawRequest = null;
        this.draw();
      });
    }

    // Draw each new video frame with requestVideoFrameCallback.
    watchFrames() {
      if (!HAS_FRAME_CALLBACK || this.frameRequest !== null) return;
      this.frameRequest = this.video.requestVideoFrameCallback(() => {
        this.frameRequest = null;
        this.drawFrame();
        this.watchFrames();
      });
    }

    // Fallback without requestVideoFrameCallback: draw in each animation frame while the video plays.
    startLoop() {
      if (this.loopRequest !== null) return;
      const tick = () => {
        if (this.video.paused) {
          this.loopRequest = null;
          return;
        }
        this.drawFrame();
        this.loopRequest = requestAnimationFrame(tick);
      };
      this.loopRequest = requestAnimationFrame(tick);
    }

    drawFrame() {
      this.draw();
      if (this.onVideoFrame) this.onVideoFrame();
    }
  }

  // One section: the scene tabs, the Resync button, and one to three players. All players of a section show the same scene.
  class FlythroughGroup {
    constructor(container, config) {
      this.config = config;
      this.scene = null;
      this.visible = false;
      this.resyncing = false; // True while a resync waits for the seeks of its videos.
      this.resyncCount = 0; // Number of resyncs. A newer resync cancels an older resync that still waits.

      const bar = element('div', 'scene-bar');
      const tabs = element('div', 'scene-tabs');
      tabs.setAttribute('role', 'group');
      tabs.setAttribute('aria-label', 'Scenes');
      const resync = element('button', 'resync-button', 'Resync');
      resync.type = 'button';
      resync.addEventListener('click', () => this.resync());
      bar.append(tabs, resync);
      // The player count selects the layout class: one, two, or three players.
      const layout = ['player-single', 'player-pair', 'player-triple'][config.players.length - 1];
      const players = element('div', layout);
      container.append(bar, players);

      this.players = config.players.map((player) => new ComparePlayer(players, player.title, player.single));
      this.buttons = config.scenes.map((scene) => {
        const button = element('button', 'scene-tab', scene.label);
        button.type = 'button';
        if (scene.tooltip) button.title = scene.tooltip;
        button.addEventListener('click', () => this.select(scene));
        tabs.appendChild(button);
        return button;
      });

      if (this.players.length > 1) this.players[0].onVideoFrame = () => this.syncFollowers();

      // Play the videos while a player of the section is on screen. Pause them when no player is on screen.
      const onScreen = new Set();
      const observer = new IntersectionObserver((entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) onScreen.add(entry.target);
          else onScreen.delete(entry.target);
        });
        this.setVisible(onScreen.size > 0);
      });
      this.players.forEach((player) => observer.observe(player.stage));

      this.select(config.scenes[0]);
    }

    select(scene) {
      if (scene === this.scene) return;
      this.scene = scene;
      this.config.scenes.forEach((item, i) => {
        this.buttons[i].setAttribute('aria-pressed', item === scene ? 'true' : 'false');
      });
      this.players.forEach((player, i) => {
        player.setSource(VIDEO_ROOT + '/' + this.config.players[i].dataset + '/' + scene.id + '.mp4');
      });
      // All videos of the new scene start together at time 0.
      this.resync();
    }

    setVisible(visible) {
      if (visible === this.visible) return;
      this.visible = visible;
      // During a resync the videos stay paused. The resync starts them when it ends.
      if (this.resyncing) return;
      this.players.forEach((player) => {
        if (visible) playQuietly(player.video);
        else player.video.pause();
      });
    }

    // Start all videos of the section together at time 0: pause all, seek all to 0, wait for all seeks, play all.
    resync() {
      const count = ++this.resyncCount;
      this.resyncing = true;
      const videos = this.players.map((player) => player.video);
      videos.forEach((video) => video.pause());
      Promise.all(videos.map(seekToStart)).then(() => {
        if (count !== this.resyncCount) return;
        this.resyncing = false;
        if (this.visible) videos.forEach(playQuietly);
      });
    }

    // Each follower uses the clock of the leader. Seek a follower when its drift is more than MAX_DRIFT.
    // A resync stops this drift correction until all videos play again from time 0.
    syncFollowers() {
      if (this.resyncing) return;
      const leader = this.players[0].video;
      if (leader.seeking) return;
      const duration = leader.duration;
      for (let i = 1; i < this.players.length; i++) {
        const follower = this.players[i].video;
        if (follower.seeking || follower.readyState < HAVE_CURRENT_DATA) continue;
        let drift = follower.currentTime - leader.currentTime;
        // The two videos do not loop at the same instant. Measure the drift across the loop point.
        if (duration > 0 && Number.isFinite(duration)) drift -= duration * Math.round(drift / duration);
        if (Math.abs(drift) > MAX_DRIFT) follower.currentTime = leader.currentTime;
      }
    }
  }

  document.querySelectorAll('[data-flythrough]').forEach((container) => {
    const config = FLYTHROUGHS[container.dataset.flythrough];
    if (config) new FlythroughGroup(container, config);
    else console.warn('compare.js: no scene table entry for', container.dataset.flythrough);
  });
})();
