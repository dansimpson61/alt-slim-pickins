// Everything the server could not do, and nothing it could.
//
// roth's original script was 276 lines: it drew the chart, formatted every
// figure, toggled two disclosures, rendered the results from JSON and followed
// the pointer with a hand-built tooltip. All of that is Ruby now — the last of
// it in Phase 8, when `chart` learned to put the numbers in a <title> and the
// browser started showing them for free.
//
// What is left is the one job a server genuinely cannot do: ask for a fresh
// projection without a reload.
(function () {
  const form = document.getElementById('scenario');
  if (!form) return;

  const box = () => document.querySelector('.section--projection');

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
    const here = box();
    if (!here) return;
    here.setAttribute('aria-busy', 'true');
    const res = await fetch('/projection', { method: 'POST', body: new FormData(form) });
    if (!res.ok) {
      here.removeAttribute('aria-busy');
      return;
    }
    here.outerHTML = await res.text();
  }
})();
