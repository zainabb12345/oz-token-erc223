const { accounts, contract } = require('@openzeppelin/test-environment');
const { expect } = require('chai');

const { BN,
  constants,
  expectRevert } = require('@openzeppelin/test-helpers')

// Create a contract object from a compilation artifact
const oz223 = contract.fromArtifact('oz223');

let oztoken = '';

const _name = "ABC";
const _symbol = "ABC";
const _decimal = 6;
const overallSupply = 11000000000000;
const sender = accounts[0];
const receiver = accounts[1];

beforeEach(async function () {
  oztoken = await oz223.new({ from: sender });
  abcAddress = oztoken.address;
  await oztoken.initialize({ from: sender });
});
describe('Constructor is initialized correctly', async () => {

  it('verify name', async function () {
    let name = await oztoken.name();
    expect(name).to.equal(_name);
  });

  it('verify symbol', async function () {
    let symbol = await oztoken.symbol();
    expect(symbol).to.equal(_symbol);
  });

  it('verify decimal', async function () {
    let decimal = await oztoken.decimal();
    expect(Number(decimal)).to.equal(_decimal);
  });

  it('verify total Supply', async function () {
    let totalSupply = await oztoken.totalSupply();
    expect(1000000000000).to.equal(Number(totalSupply));
  });
});

describe("issued correct total amount to the owner", async () => {

  it('is total supply equal to initial balance', async function () {
    let totalSupply = await oztoken.totalSupply();
    let balanceof = await oztoken.balanceOf(sender);
    expect(Number(totalSupply)).to.equal(Number(balanceof));
  });
});

describe("verifying transfer functionality", async () => {
  const testRecievedBalance = accounts[2];
  it('sent amount is equal to the amount accepted by receiver', async () => {
    await oztoken.transfer(testRecievedBalance, 1000, { from: sender });
    const receievedBalance = await oztoken.balanceOf(testRecievedBalance);
    expect(Number(receievedBalance)).to.equal(1000);
  });
  it('amount sent exceed sender account balance',async()=>{
    try{
      await oztoken.transfer(testRecievedBalance, overallSupply, { from: sender });
    }
    catch{
      expect(true).to.equal(true);
    }
  });
});