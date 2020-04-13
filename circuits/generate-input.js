const fs = require('fs');
const crypto = require('crypto');
const bigInt = require('big-integer');
const { stringifyBigInts } = require('snarkjs');
const mimcjs = require('../node_modules/circomlib/src/mimc7.js');

// guess is table
var pubGuess = [116, 97, 98, 112, 113];
// solution is taboo
var privSolution = [116, 97, 98, 113, 112];
// since guess < solution (lexicographically)
// not equal
var pubComparison = 0;
// less than
var pubComparisonLessThan = 1;
// not greater than
var pubComparisonGreaterThan = 0;
// salt for hashing (random number)
var privSalt = bigInt(crypto.randomBytes(4).toString('hex'), 16).toJSNumber();
// hash of the private solution
var arrayIn = [];
for (var i = 0; i < 5; i++) {
  arrayIn.push(privSolution[i] + privSalt);
}
var pubSolutionHash = mimcjs.multiHash(arrayIn, bigInt(privSalt));

const inputs = {
    pubGuess: pubGuess,
    privSolution: privSolution,
    pubComparison: pubComparison,
    pubComparisonLessThan: pubComparisonLessThan,
    pubComparisonGreaterThan: pubComparisonGreaterThan,
    privSalt: privSalt,
    pubSolutionHash: pubSolutionHash.toString(),
};

fs.writeFileSync(
    './input.json',
    JSON.stringify(inputs),
    'utf-8'
);
