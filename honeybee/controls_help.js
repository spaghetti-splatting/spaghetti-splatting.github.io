// Controls help panel of the WebGPU viewer. This module is additive: index.html loads it, no other file changes.
// The panel lists the mouse and key bindings of nav.js and main.js for the current navigation mode.
// The module also hides the dataset view stepper and the capture cameras of the shot tool.

const $ = (id) => document.getElementById(id);
const TOGGLE_CODE = 'KeyI';  // main.js uses H for the full help (#help), so the panel uses I.
const TOGGLE_LABEL = 'I';

// Mouse glyph: outline mouse, the active part filled white.
function mouse(part) {
  const fill = {
    left: '<path d="M7 1.5A5.5 5.5 0 0 0 1.5 7V10H7Z" fill="#fff"/>',
    right: '<path d="M7 1.5A5.5 5.5 0 0 1 12.5 7V10H7Z" fill="#fff"/>',
    wheel: '<rect x="6" y="4" width="2" height="5" rx="1" fill="#fff"/>',
  }[part];
  const split = part === 'wheel' ? '' : '<path d="M7 1.5V10M1.5 10H12.5" stroke="currentColor" stroke-width="1.1" fill="none"/>';
  return `<svg class="ch-mouse" viewBox="0 0 14 22" width="15" height="23" aria-hidden="true">${fill}${split}`
    + '<rect x="1.5" y="1.5" width="11" height="19" rx="5.5" fill="none" stroke="currentColor" stroke-width="1.3"/></svg>';
}
const MOVE = '<svg class="ch-move" viewBox="0 0 16 16" width="15" height="15" aria-hidden="true"><path d="M8 1L10.5 3.5H9V7H12.5'
  + 'V5.5L15 8L12.5 10.5V9H9V12.5H10.5L8 15L5.5 12.5H7V9H3.5V10.5L1 8L3.5 5.5V7H7V3.5H5.5Z" fill="none" stroke="currentColor"'
  + ' stroke-width="1" stroke-linejoin="round"/></svg>';
const drag = (part) => MOVE + mouse(part);
const dbl = (part) => `<span class="ch-x2">×2</span>${mouse(part)}`;
const keys = (...k) => k.map((x) => `<kbd class="ch-key">${x}</kbd>`).join('');
const ICON = {
  orbit: '<svg class="ch-icon" viewBox="0 0 24 24" width="22" height="22" aria-hidden="true" fill="none" stroke="currentColor"'
    + ' stroke-width="1.6"><circle cx="12" cy="12" r="5.5"/><ellipse cx="12" cy="12" rx="10.5" ry="4" transform="rotate(-30 12 12)"/></svg>',
  walk: '<svg class="ch-icon" viewBox="0 0 24 24" width="22" height="22" aria-hidden="true" fill="none" stroke="currentColor"'
    + ' stroke-width="1.6" stroke-linejoin="round"><path d="M12 3L19.5 20L12 16L4.5 20Z"/></svg>',
};

// Bindings of nav.js (_attach, _down, update) and main.js (bindUi).
const ROWS = {
  orbit: [
    ['Orbit', drag('left')],
    ['Pan', drag('right')],
    ['Zoom', mouse('wheel')],
    ['Focus on Point', dbl('left')],
    ['Roll', keys('[', ']')],
    ['Level Horizon', keys('\\')],
    ['Reset View', keys('R')],
    ['Walk Mode', keys('Tab')],
    ['Full Screen', keys('F')],
    ['Primitive View', keys('P')],
    ['Split View', keys('V')],
  ],
  walk: [
    ['Move', keys('W', 'A', 'S', 'D')],
    ['Down / Up', keys('Q', 'E')],
    ['Turn', keys('←', '↑', '↓', '→')],
    ['Look', drag('left')],
    ['Slide', drag('right')],
    ['Forward / Back', mouse('wheel')],
    ['Faster (hold)', keys('Shift')],
    ['Focus on Point', dbl('left')],
    ['Roll', keys('[', ']')],
    ['Level Horizon', keys('\\')],
    ['Reset View', keys('R')],
    ['Orbit Mode', keys('Tab')],
    ['Full Screen', keys('F')],
    ['Primitive View', keys('P')],
    ['Split View', keys('V')],
  ],
};
const TOGGLES = [['Toggle Controls', keys(TOGGLE_LABEL)], ['Full Help', keys('H')]];

const panel = document.createElement('div');
panel.id = 'controls-help';
panel.setAttribute('role', 'dialog');
document.body.appendChild(panel);

function render() {
  const m = $('mode-walk')?.classList.contains('on') ? 'walk' : 'orbit';
  const rows = (list) => list.map(([name, glyph]) => `<div class="ch-row"><span>${name}</span><span class="ch-glyph">${glyph}</span></div>`).join('');
  panel.setAttribute('aria-label', m === 'walk' ? 'Walk Mode controls' : 'Orbit Mode controls');
  panel.innerHTML = `<div class="ch-head">${ICON[m]}<b>${m === 'walk' ? 'Walk' : 'Orbit'} Mode</b>`
    + `<button class="ch-close" title="Close (${TOGGLE_LABEL})" aria-label="Close">✕</button></div>`
    + `<div class="ch-sep"></div>${rows(ROWS[m])}<div class="ch-sep"></div>${rows(TOGGLES)}`;
  panel.querySelector('.ch-close').onclick = () => {
    panel.classList.add('ch-gone');
    $('view')?.focus({preventScroll: true});
  };
}
render();

// main.js setMode toggles the class "on" of the mode buttons: show the rows of the new mode.
const watch = new MutationObserver(render);
for (const id of ['mode-orbit', 'mode-walk']) if ($(id)) watch.observe($(id), {attributes: true, attributeFilter: ['class']});

document.addEventListener('keydown', (e) => {
  if (e.code !== TOGGLE_CODE || e.metaKey || e.ctrlKey || e.altKey || e.repeat) return;
  const t = e.target;
  if (t instanceof HTMLInputElement || t instanceof HTMLSelectElement || t instanceof HTMLTextAreaElement || t?.isContentEditable) return;
  panel.classList.toggle('ch-gone');
});

// Hide the dataset view stepper. Hide its container only if the container holds nothing else.
for (const id of ['view-prev', 'view-label', 'view-next']) $(id)?.classList.add('ch-gone');
const box = $('view-label')?.parentElement;
if (box && [...box.children].every((c) => c.classList.contains('ch-gone'))) box.classList.add('ch-gone');

// Hide the capture cameras of the shot tool: uncheck the box, send its change event, hide its label.
const cams = $('shot-show-cams');
if (cams) {
  const off = () => { cams.checked = false; cams.dispatchEvent(new Event('change', {bubbles: true})); };
  off();
  cams.closest('label')?.classList.add('ch-gone');
  // main.js init makes the shot tool (and its change handler) after an await: send the event again then.
  let tries = 0;
  const wait = setInterval(() => {
    if (window.__kc?.shot || ++tries > 600) { clearInterval(wait); off(); }
  }, 200);
}
