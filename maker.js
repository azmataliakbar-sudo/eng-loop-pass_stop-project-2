const fs = require('fs');
const path = require('path');

const fixesFile = path.join(__dirname, 'fixes-applied.txt');
const srcFile = path.join(__dirname, 'src', 'calc.js');

const versions = [
  `function add(a, b) { return a - b; }
function subtract(a, b) { return a + b; }
function multiply(a, b) { return a / b; }
module.exports = { add, subtract, multiply };
`,
  `function add(a, b) { return a + b; }
function subtract(a, b) { return a + b; }
function multiply(a, b) { return a / b; }
module.exports = { add, subtract, multiply };
`,
  `function add(a, b) { return a + b; }
function subtract(a, b) { return a - b; }
function multiply(a, b) { return a / b; }
module.exports = { add, subtract, multiply };
`,
  `function add(a, b) { return a + b; }
function subtract(a, b) { return a - b; }
function multiply(a, b) { return a * b; }
module.exports = { add, subtract, multiply };
`,
];

// The loop.ps1 passes the next fix number as the first argument.
const nextIndex = parseInt(process.argv[2] || '0', 10);
const clamped = Math.min(Math.max(nextIndex, 0), versions.length - 1);
fs.writeFileSync(srcFile, versions[clamped]);
