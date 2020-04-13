include "../node_modules/circomlib/circuits/comparators.circom";
include "../node_modules/circomlib/circuits/mimc.circom";

template Main(n) {
  // n defines the max length of word

  // define public inputs
  // pubGuess is the word guessed by player
  // the word is represented in small case
  // every character is encoded to its ASCII value
  // if a word has less than `n` characters, it is right-padded with 0
  signal input pubGuess[n];
  // pubComparison is either 0 or 1
  // 0 signifies the guess does not match the secret word lexicographically
  // 1 signifies the guess matches the secret word
  signal input pubComparison;
  // pubComparisonLessThan is either 0 or 1
  // 0 signifies the guess is NOT less than the secret word
  // 1 signifies the guess is less than the secret word
  signal input pubComparisonLessThan;
  // pubComparisonGreaterThan is either 0 or 1
  // 0 signifies the guess is NOT greater than the secret word
  // 1 signifies the guess is greater than the secret word
  signal input pubComparisonGreaterThan;
  // pubSolutionHash is the pederson hash of the secret word
  // pederson hash encodes the word to a compressed point on an elliptic curve
  signal input pubSolutionHash;

  // define private inputs
  // privSolution is the secret word for the game round
  signal private input privSolution[n];
  // privSalt is a salt added to each character of solution
  // this is then used to calculate the public hash of solution
  signal input privSalt;

  // define output
  signal output solutionHashOut;

  component lt[n];
  component gt[n];
  var mappedGuess = 0;
  var mappedSolution = 0;
  var i;
  for (i = 0; i < n; i++) {
    // ensure that characters are small cased
    // ASCII values of small cased letters are between a=97 to z=122
    lt[i] = LessThan(6);
    gt[i] = GreaterThan(6);
    lt[i].in[0] <== privSolution[i];
    lt[i].in[1] <== 123;
    gt[i].in[0] <== privSolution[i];
    gt[i].in[1] <== 96;
    lt[i].out === 1;
    gt[i].out === 1;

    // map guess and solution to single number
    mappedGuess = mappedGuess + (pubGuess[n-1-i] * (26**i));
    mappedSolution = mappedSolution + (privSolution[n-1-i] * (26**i));
  }

  // constraint for matching guess and solution
  component comparison = IsEqual();
  comparison.in[0] <== mappedGuess;
  comparison.in[1] <== mappedSolution;
  comparison.out === pubComparison;

  // 26 bits to represent MAX_MAPPED_VALUE
  // MAX_MAPPED_VALUE = 122 * (26**0 + 26**1 + 26**2 + ... + 26**(n-1))
  // m = ceil(log(MAX_MAPPED_VALUE))
  var m = 26;

  // constraint for guess less than solution
  component comparisonLessThan = LessThan(m);
  comparisonLessThan.in[0] <== mappedGuess;
  comparisonLessThan.in[1] <== mappedSolution;
  comparisonLessThan.out === pubComparisonLessThan;

  // constraint for guess greater than solution
  component comparisonGreaterThan = GreaterThan(m);
  comparisonGreaterThan.in[0] <== mappedGuess;
  comparisonGreaterThan.in[1] <== mappedSolution;
  comparisonGreaterThan.out === pubComparisonGreaterThan;

  // compute hash of the salted solution
  component mimcHashSolution = MultiMiMC7(n, 91);
  for (i = 0; i < n; i++) {
    mimcHashSolution.in[i] <== privSolution[i] + privSalt;
  }
  mimcHashSolution.k <== privSalt;

  solutionHashOut <== mimcHashSolution.out;

  pubSolutionHash === mimcHashSolution.out;
}

component main = Main(5);
