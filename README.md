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

### Contracts

- Event Hub (Events Creator & Event State Mangement)
  - Governor (Token & Timelock Contracts)
  - Treasury (contribute / release / lock / unlock / claim / setSchedule)
  - Randomised NFT (Create -> mintRandom)
- Social Hub (User NFT)
  - Subscribtion NFT (Expirable / User NFT Linkable)
  - Content NFT (Access Token / L. Edition / User NFT Linkable)

#### Event Flow

Events can be in 5 states:

- Fund Raising (Show plans, Active in chat)
  - Publish (onlyOrganiser)
  - Contribute Funds => Get DAO Token / Attendance NFT
  - End Event (votable)
- Fund Collected (Sending updates, Active in chat)
  - Release Funds (onlyOwner / onlyCause / votable / any)
  - Lock / Unlock Funds (onlyOwner / votable)
  - Post Suggestion (onlySponsor / votable)
  - End Event (votable)
- Event Now (Optional for Actual Event Date)
  - Token Gating (attendees)
  - NFT Minting (onlyOwner / onlyContract / votable)
- Event Ended
  - Report Organizer (votable)
  - Attendance NFT Evolution
  - Return Funds => Burn DAO Token

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
