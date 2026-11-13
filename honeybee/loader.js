// Loading screen of the WebGPU hair viewer: a plate of spaghetti.
// The module watches the #progress, #warning and #fps texts of viewer.js
// with MutationObserver. It imports nothing from viewer.js. With parity=1 or
// orbit_test=1 in the URL, it does nothing: the automatic tests see the same
// page as before.

const NS = 'http://www.w3.org/2000/svg';
const C = 120;  // Centre of the plate in SVG user units.

const STYLE = `
#loader { position: fixed; inset: 0; z-index: 10; display: flex; flex-direction: column;
  align-items: center; justify-content: center; gap: 16px; padding: 16px; text-align: center;
  background: radial-gradient(circle at 50% 40%, #1d1712 0%, #000 70%); color: #e9dcc5;
  font-family: system-ui, sans-serif; transition: opacity 0.5s, visibility 0s; }
#loader.kc-gone { opacity: 0; visibility: hidden; pointer-events: none;
  transition: opacity 0.5s, visibility 0s 0.5s; }
#loader svg { display: block; }
#loader .kc-steam, #loader .kc-plate { width: min(64vw, 300px); }
#loader .kc-nest { transform-origin: 120px 120px; }
#loader .kc-title { font-size: 20px; font-weight: 600; }
#loader .kc-sub { font-size: 13px; color: #bfae92; }
#loader .kc-bar { width: min(70vw, 320px); height: 18px; }
#loader .kc-front { transition: stroke-dashoffset 0.3s; }
#loader .kc-status, #loader .kc-warn { font: 12px monospace; color: #bfae92; max-width: 90vw;
  overflow-wrap: anywhere; }
#loader .kc-warn, #loader.kc-error .kc-status { color: #ff8a3d; }
#loader.kc-error .kc-bar { display: none; }
`;

// Make an SVG element with the attributes and append it to the parent.
function svg(tag, attrs, parent) {
  const node = document.createElementNS(NS, tag);
  for (const [key, value] of Object.entries(attrs)) node.setAttribute(key, value);
  parent.appendChild(node);
  return node;
}

function div(className, parent, text = '') {
  const node = document.createElement('div');
  node.className = className;
  node.textContent = text;
  parent.appendChild(node);
  return node;
}

// mulberry32 PRNG: one seed gives the same plate at every load.
function mulberry32(seed) {
  return () => {
    seed = (seed + 0x6D2B79F5) | 0;
    let t = Math.imul(seed ^ (seed >>> 15), seed | 1);
    t ^= t + Math.imul(t ^ (t >>> 7), t | 61);
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
}

// Uniform Catmull-Rom spline through the points, as cubic Bezier segments.
// An open spline repeats its end points. A closed spline wraps around.
function catmullRom(points, closed) {
  const n = points.length;
  const at = (i) => points[closed ? (i + n) % n : Math.min(n - 1, Math.max(0, i))];
  const xy = (p) => `${p[0].toFixed(2)} ${p[1].toFixed(2)}`;
  let d = `M${xy(points[0])}`;
  for (let i = 0; i < (closed ? n : n - 1); i++) {
    const [a, b, c, e] = [at(i - 1), at(i), at(i + 1), at(i + 2)];
    d += `C${xy([b[0] + (c[0] - a[0]) / 6, b[1] + (c[1] - a[1]) / 6])} ` +
         `${xy([c[0] - (e[0] - b[0]) / 6, c[1] - (e[1] - b[1]) / 6])} ${xy(c)}`;
  }
  return closed ? `${d}Z` : d;
}

function start() {
  const still = matchMedia('(prefers-reduced-motion: reduce)').matches;
  const progress = document.getElementById('progress');
  const warning = document.getElementById('warning');
  const style = document.createElement('style');
  style.textContent = STYLE;
  document.head.appendChild(style);
  const root = document.createElement('div');
  root.id = 'loader';
  const dish = div('', root);

  // Steam: three wavy lines above the plate. Reduced motion: no steam.
  const steamLines = [];
  if (!still) {
    const steam = svg('svg', {class: 'kc-steam', viewBox: '0 0 240 60', fill: 'none',
      stroke: 'rgba(255,255,255,0.35)', 'stroke-width': 3, 'stroke-linecap': 'round'}, dish);
    for (const x of [96, 120, 144]) {
      steamLines.push(svg('path', {opacity: 0,
        d: `M${x} 56C${x - 7} 49 ${x + 7} 43 ${x} 36S${x + 7} 23 ${x} 16`}, steam));
    }
  }

  // Plate, top view: soft shadow, plate, inner well.
  const plate = svg('svg', {class: 'kc-plate', viewBox: '0 0 240 240'}, dish);
  const defs = svg('defs', {}, plate);
  svg('feGaussianBlur', {stdDeviation: 6}, svg('filter', {id: 'kc-blur'}, defs));
  for (const [id, inner, outer] of [['kc-china', '#f4f1ea', '#d6cfc2'],
                                    ['kc-sauce', '#d9482f', '#b8321f']]) {
    const gradient = svg('radialGradient', {id}, defs);
    svg('stop', {offset: 0, 'stop-color': inner}, gradient);
    svg('stop', {offset: 1, 'stop-color': outer}, gradient);
  }
  svg('circle', {cx: C, cy: C + 8, r: 104, fill: 'rgba(0,0,0,0.55)', filter: 'url(#kc-blur)'}, plate);
  svg('circle', {cx: C, cy: C, r: 104, fill: 'url(#kc-china)', stroke: '#bfb8aa', 'stroke-width': 2}, plate);
  svg('circle', {cx: C, cy: C, r: 72, fill: '#ebe6dc', stroke: 'rgba(0,0,0,0.08)', 'stroke-width': 3}, plate);

  // Noodle nest: 16 strands from the seeded PRNG, then the sauce and two
  // basil leaves. The whole nest turns.
  const nest = svg('g', {class: 'kc-nest'}, plate);
  const noodles = svg('g', {fill: 'none', 'stroke-linecap': 'round', 'stroke-linejoin': 'round'}, nest);
  const rand = mulberry32(7);
  const strands = [];
  for (let i = 0; i < 16; i++) {
    const count = 9 + Math.floor(rand() * 4);
    let theta = rand() * 2 * Math.PI;
    const points = [];
    for (let k = 0; k < count; k++) {
      const r = 18 + 48 * rand();
      points.push([C + r * Math.cos(theta), C + r * Math.sin(theta)]);
      theta += 0.9 + 0.5 * rand();
    }
    const d = catmullRom(points, false);
    const strand = svg('g', {}, noodles);
    svg('path', {d, stroke: '#c8922e', 'stroke-width': 5.5}, strand);
    svg('path', {d, stroke: '#f6d27a', 'stroke-width': 3.5}, strand);
    svg('path', {d, stroke: '#fff3c4', 'stroke-width': 1, opacity: 0.6}, strand);
    strands.push(strand);
  }
  const blob = [];
  for (let k = 0; k < 9; k++) {
    const phi = (2 * Math.PI * k) / 9;
    const r = 17 + 6 * rand();
    blob.push([C + r * Math.cos(phi), C + r * Math.sin(phi)]);
  }
  svg('path', {d: catmullRom(blob, true), fill: 'url(#kc-sauce)', opacity: 0.92}, nest);
  for (const [cx, cy, r] of [[113, 114, 2], [127, 117, 1.6], [117, 127, 1.8], [126, 127, 1.3]]) {
    svg('circle', {cx, cy, r, fill: '#8f2415'}, nest);
  }
  for (const transform of ['translate(129 108) rotate(-38)', 'translate(110 132) rotate(146)']) {
    const leaf = svg('g', {transform}, nest);
    svg('path', {d: 'M0 0C5-7 13-7 18 0C13 7 5 7 0 0Z', fill: '#3f8f3a'}, leaf);
    svg('path', {d: 'M1.5 0H16', stroke: '#2c6b29', 'stroke-width': 0.8}, leaf);
  }

  const titles = div('', root);
  div('kc-title', titles, 'Spaghetti Splatting');
  div('kc-sub', titles, 'WebGPU viewer · hair and scenes');

  // Progress bar: a wavy noodle, 2.5 periods of a sine with amplitude 4.
  const bar = svg('svg', {class: 'kc-bar', viewBox: '0 0 320 18', fill: 'none',
    'stroke-width': 4, 'stroke-linecap': 'round'}, root);
  const wave = [];
  for (let k = 0; k <= 40; k++) wave.push([4 + (312 * k) / 40, 9 + 4 * Math.sin((5 * Math.PI * k) / 40)]);
  svg('path', {d: catmullRom(wave, false), stroke: '#3a2f22'}, bar);
  const front = svg('path', {class: 'kc-front', d: catmullRom(wave, false), stroke: '#f2c75c'}, bar);
  const lines = div('', root);
  const status = div('kc-status', lines);
  const warn = div('kc-warn', lines);
  document.body.appendChild(root);

  // Each strand draws in, holds, and draws out. The three paths of a strand
  // inherit the dash values of the strand group, so they move together.
  const motion = [];  // Rotation and strands: the error state stops them.
  const steam = steamLines.map((line, i) => line.animate([
    {transform: 'translateY(0px)', opacity: 0},
    {opacity: 0.5, offset: 0.5},
    {transform: 'translateY(-10px)', opacity: 0},
  ], {duration: 2400, delay: 800 * i, iterations: Infinity}));
  if (!still) {
    motion.push(nest.animate([{transform: 'rotate(0deg)'}, {transform: 'rotate(360deg)'}],
                             {duration: 14000, iterations: Infinity}));
    strands.forEach((strand, i) => {
      const length = strand.firstChild.getTotalLength();
      strand.style.strokeDasharray = `${length}px`;
      strand.style.strokeDashoffset = `${length}px`;
      motion.push(strand.animate([
        {strokeDashoffset: `${length}px`, easing: 'ease-in-out'},
        {strokeDashoffset: '0px', offset: 0.4},
        {strokeDashoffset: '0px', offset: 0.75, easing: 'ease-in-out'},
        {strokeDashoffset: `${-length}px`},
      ], {duration: 4800, delay: 120 * i, iterations: Infinity}));
    });
  }

  // The front path shows the fraction f = k/n of the #progress text. With no
  // fraction, a short dash sweeps along the noodle.
  const total = front.getTotalLength();
  const dash = 0.15 * total;
  const sweep = front.animate([{strokeDashoffset: `${dash}px`}, {strokeDashoffset: `${-total}px`}],
                              {duration: 1600, easing: 'ease-in-out', iterations: Infinity});
  let sweeping = true;
  // Set the front path to zero length without the transition.
  function zero() {
    front.style.transition = 'none';
    front.style.strokeDashoffset = `${total}px`;
    getComputedStyle(front).strokeDashoffset;  // Apply the zero before the transition returns.
    front.style.transition = '';
  }
  function setBar(f) {
    if (f === null) {
      sweeping = true;
      front.style.strokeDasharray = `${dash}px ${total + dash}px`;
      return;
    }
    if (sweeping) {
      sweeping = false;
      sweep.cancel();
      zero();
    }
    front.style.strokeDasharray = `${total}px`;
    front.style.strokeDashoffset = `${total * (1 - f)}px`;
  }

  let timer = 0;  // Hide time-out after a "loaded" message; 0 when there is no wait.
  const run = (animation, on) => (on ? animation.play() : animation.pause());
  // The animations run only while the loader shows. The error state stops
  // the strands and the rotation.
  function sync() {
    const shown = !root.classList.contains('kc-gone');
    const error = root.classList.contains('kc-error');
    motion.forEach((a) => run(a, shown && !error));
    steam.forEach((a) => run(a, shown));
    if (sweeping) run(sweep, shown && !error);
  }
  // Fade out. sync() stops the animations at the end of the fade.
  function hide() {
    clearTimeout(timer);
    timer = 0;
    root.classList.add('kc-gone');
  }
  function update() {
    const text = progress.textContent;
    const error = text.startsWith('error:');
    const loaded = text.startsWith('loaded ');
    const match = text.match(/\((\d+)\/(\d+)\)$/);
    clearTimeout(timer);
    timer = loaded ? setTimeout(hide, 3000) : 0;
    if (text.startsWith('loading ') && root.classList.contains('kc-gone')) {
      root.classList.remove('kc-gone');  // Model switch: show again from zero.
      zero();
    }
    root.classList.toggle('kc-error', error);
    // George: the loader shows no model name or load text. Only an error shows.
    status.textContent = error ? text : '';
    setBar(loaded ? 1 : match ? match[1] / match[2] : null);
    sync();
  }

  const watch = (id, callback) => new MutationObserver(callback).observe(
      document.getElementById(id), {childList: true, characterData: true, subtree: true});
  watch('progress', update);
  watch('warning', () => { warn.textContent = warning.textContent; });
  watch('fps', () => { if (timer) hide(); });
  root.addEventListener('transitionend', sync);
  warn.textContent = warning.textContent;
  update();
}

const params = new URLSearchParams(location.search);
if (params.get('parity') !== '1' && params.get('orbit_test') !== '1') start();
