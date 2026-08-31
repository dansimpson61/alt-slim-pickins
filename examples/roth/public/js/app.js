// Everything the server could not do, and nothing it could.
//
// roth's original script was 276 lines: it drew the chart, formatted every
// figure, toggled two disclosures, and rendered the results from JSON. All of
// that is now Ruby. What is left is the two jobs a server genuinely cannot do
// — ask for a fresh projection without a page reload, and follow the pointer.
(function () {
  const form = document.getElementById('scenario');
  if (!form) return;

  const region = () => document.querySelector('.section--projection');

  let pending;
  form.addEventListener('input', () => {
    clearTimeout(pending);
    pending = setTimeout(refresh, 450);
  });
  form.addEventListener('submit', (e) => {
    e.preventDefault();
    refresh();
  });

  async function refresh() {
    const here = region();
    if (!here) return;
    here.setAttribute('aria-busy', 'true');
    const res = await fetch('/projection', { method: 'POST', body: new FormData(form) });
    if (!res.ok) {
      here.removeAttribute('aria-busy');
      return;
    }
    here.outerHTML = await res.text();
    follow();
  }

  // Each chart column carries its own year and its own numbers, drawn into the
  // SVG on the server. This places a box; it never computes a scale.
  function follow() {
    document.querySelectorAll('.drawing').forEach((frame) => {
      const tip = frame.querySelector('.drawing-tip');
      if (!tip) return;

      frame.querySelectorAll('.chart-hit').forEach((hit) => {
        hit.addEventListener('mouseenter', () => {
          tip.textContent = hit.dataset.year + ' — ' + hit.dataset.detail;
          tip.hidden = false;
        });
      });
      frame.addEventListener('mousemove', (e) => {
        const box = frame.getBoundingClientRect();
        tip.style.left = e.clientX - box.left + 14 + 'px';
        tip.style.top = e.clientY - box.top + 14 + 'px';
      });
      frame.addEventListener('mouseleave', () => {
        tip.hidden = true;
      });
    });
  }

  follow();
})();
