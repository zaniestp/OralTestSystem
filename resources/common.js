/**
 * common.js — Shared security and utilities
 * Reading Activity Player  |  Offline Edition
 *
 * NOTE: All pages run inside an <iframe> hosted by index.html (the shell).
 * The shell owns fullscreen — these pages never call requestFullscreen().
 * Navigation is done via parent.loadPage(url) instead of window.location.
 */
'use strict';

/* ═══════════════════════════════════════════════════════════════
   SECURITY — applied immediately on script load
═══════════════════════════════════════════════════════════════ */

document.addEventListener('contextmenu', function (e) {
  e.preventDefault(); return false;
});

document.addEventListener('selectstart', function (e) {
  e.preventDefault(); return false;
});

document.addEventListener('dragstart', function (e) {
  e.preventDefault(); return false;
});

document.addEventListener('keydown', function (e) {
  if (e.ctrlKey || e.metaKey) {
    e.preventDefault(); e.stopPropagation(); return false;
  }
  if (e.altKey) {
    e.preventDefault(); e.stopPropagation(); return false;
  }
  if (/^F\d{1,2}$/.test(e.key) || e.key === 'Escape') {
    e.preventDefault(); return false;
  }
}, true);

document.addEventListener('mousedown', function (e) {
  if (e.button === 3 || e.button === 4) {
    e.preventDefault(); return false;
  }
}, true);

/* ═══════════════════════════════════════════════════════════════
   NAVIGATION
   Pages run inside the shell iframe (index.html).
   postMessage is used so navigation works on file:// protocol
   where direct parent.x() calls are blocked as cross-origin.
   The shell listens for { type:'ra_navigate', url:'...' }.
   Falls back to window.location if running standalone.
═══════════════════════════════════════════════════════════════ */

function _shellNavigate(url) {
  try {
    if (window.parent && window.parent !== window) {
      window.parent.postMessage({ type: 'ra_navigate', url: url }, '*');
      return true;
    }
  } catch (e) {}
  return false;
}

function navigateTo(url) {
  if (!_shellNavigate(url)) window.location.href = url;
}

function navigateReplace(url) {
  if (!_shellNavigate(url)) window.location.replace(url);
}

/* ═══════════════════════════════════════════════════════════════
   HISTORY — prevent back-navigation within the iframe
═══════════════════════════════════════════════════════════════ */

function preventBackNavigation() {
  history.pushState(null, '', location.href);
  window.addEventListener('popstate', function () {
    history.pushState(null, '', location.href);
  });
}

/* ═══════════════════════════════════════════════════════════════
   SLIDE DETECTION
═══════════════════════════════════════════════════════════════ */

function imageExists(url) {
  return new Promise(function (resolve) {
    var img = new Image();
    img.onload  = function () { resolve(true);  };
    img.onerror = function () { resolve(false); };
    img.src = url + '?_=' + Date.now();
  });
}

function videoExists(url) {
  return new Promise(function (resolve) {
    var v = document.createElement('video');
    var done = false;
    function finish(val) { if (!done) { done = true; v.src = ''; resolve(val); } }
    v.onloadedmetadata = function () { finish(true);  };
    v.onerror          = function () { finish(false); };
    v.src = url; v.load();
    setTimeout(function () { finish(false); }, 400);  // local file — fails fast
  });
}

async function findVideoExt(basePath) {
  if (await videoExists(basePath + '.m4v')) return 'm4v';
  if (await videoExists(basePath + '.mp4')) return 'mp4';
  return null;
}

async function detectTotalSlides() {
  var count = 0;
  for (var i = 1; i <= 80; i++) {
    var base = 'resources/Slide' + i;
    var png  = await imageExists(base + '.png');
    var vext = null;
    if (!png) vext = await findVideoExt(base);
    if (png || vext) { count = i; } else { break; }
  }
  return count;
}

async function getSlideType(n, total) {
  if (n === 1 || n === total) return { type: 'image', ext: 'png' };
  var base = 'resources/Slide' + n;
  if (await imageExists(base + '.png')) return { type: 'image', ext: 'png' };
  var vext = await findVideoExt(base);
  if (vext) return { type: 'video', ext: vext };
  return { type: 'none', ext: null };
}

/* ═══════════════════════════════════════════════════════════════
   UTILITIES
═══════════════════════════════════════════════════════════════ */

function formatTime(ms) {
  var s = Math.max(0, Math.ceil(ms / 1000));
  var m = Math.floor(s / 60);
  s = s % 60;
  return String(m).padStart(2, '0') + ':' + String(s).padStart(2, '0');
}
