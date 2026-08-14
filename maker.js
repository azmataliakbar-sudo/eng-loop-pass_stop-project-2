const fs = require('fs');
const path = require('path');

const fixesFile = path.join(__dirname, 'fixes-applied.txt');
const srcFile = path.join(__dirname, 'src', 'calc.js');

const versions = [
  // 0: all broken
  `function add(a, b) { return a - b; }
function subtract(a, b) { return a + b; }
function multiply(a, b) { return a / b; }
module.exports = { add, subtract, multiply };
`,
  // 1: add fixed
  `function add(a, b) { return a + b; }
function subtract(a, b) { return a + b; }
function multiply(a, b) { return a / b; }
module.exports = { add, subtract, multiply };
`,
  // 2: add and subtract fixed
  `function add(a, b) { return a + b; }
function subtract(a, b) { return a - b; }
function multiply(a, b) { return a / b; }
module.exports = { add, subtract, multiply };
`,
  // 3: all fixed
  `function add(a, b) { return a + b; }
function subtract(a, b) { return a - b; }
function multiply(a, b) { return a * b; }
module.exports = { add, subtract, multiply };
`,
];

let fixCount = 0;
if (fs.existsSync(fixesFile)) {
  fixCount = parseInt(fs.readFileSync(fixesFile, 'utf8').trim()) || 0;
}

const nextIndex = Math.min(fixCount + 1, versions.length - 1);
fs.writeFileSync(srcFile, versions[nextIndex]);
fs.writeFileSync(fixesFile, String(nextIndex));
