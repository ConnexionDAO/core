# Core Contracts

### Installation

- Create .env file
- Setup environment

```
npm i
npm run prepare
npm i -g eslint
npm run prettier && npm run lint
```

- Run localhost scripts

```
npm run node
// OPEN NEW TERMINAL
npm run deploy
npm run sample
```

- Run testnet scripts

```
npm run testnet_deploy
npm run testnet_sample
```

#### User Experience

- Organiser create a doxxed account
- Organiser create event with raise target, description, date, and contract
- Raise amount reached => 2 weeks (adjustable) before event
- Organiser launch event (chat / activities activates)
- Proposal and votes functionality
- Event date and NFT distribution

#### Contracts

- Factory Contract (Event)
- Event Contract (Treasury, Description)
- NFT Contract (Create Token, Mint)
- Governance Contract (Create Proposal, Vote, Execute)
- Chat and Activities

#### Event Contract

- Title, Description, Org Addr
- Raise Target, Denomination
- (later)

### Ideas

- Fiver for Blockchains
- Employment / Subscription DAO Governor extension
- Social Media with DApps
- Lifeline recording for family tree, resume, etc# events-dao

### Acknowledgments

- [Openzeppelin Governance Walkthrough](https://docs.openzeppelin.com/contracts/4.x/governance)
- [Openzeppelin Governance Github](https://github.com/OpenZeppelin/openzeppelin-contracts/tree/master/contracts/governance)
- [Vitalik on DAOs](https://blog.ethereum.org/2014/05/06/daos-dacs-das-and-more-an-incomplete-terminology-guide/)
- [Vitalik on On-Chain Governance](https://vitalik.ca/general/2021/08/16/voting3.html)
- [Vitalik on Governance in General](https://vitalik.ca/general/2017/12/17/voting.html)
