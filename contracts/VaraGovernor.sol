// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {IGovernorUpgradeable} from "@openzeppelin/contracts-upgradeable/governance/IGovernorUpgradeable.sol";
import {IVotesUpgradeable} from "@openzeppelin/contracts-upgradeable/governance/utils/IVotesUpgradeable.sol";

import {L2Governor} from "contracts/governance/L2Governor.sol";
import {L2GovernorCountingSimple} from "contracts/governance/L2GovernorCountingSimple.sol";
import {L2GovernorVotes} from "contracts/governance/L2GovernorVotes.sol";
import {L2GovernorVotesQuorumFraction} from "contracts/governance/L2GovernorVotesQuorumFraction.sol";

contract VaraGovernor is
    Initializable,
    L2Governor,
    L2GovernorCountingSimple,
    L2GovernorVotes,
    L2GovernorVotesQuorumFraction
{
    address public team;
    uint256 public constant MAX_PROPOSAL_NUMERATOR = 50; // max 5%
    uint256 public constant PROPOSAL_DENOMINATOR = 1000;
    uint256 public proposalNumerator = 2; // start at 0.02%

    function initialize(IVotesUpgradeable _ve) external initializer {
        __L2Governor_init("Vara Governor");
        __L2GovernorVotes_init(_ve);
        __L2GovernorVotesQuorumFraction_init(4); // 4%
        team = msg.sender;
    }

    function votingDelay() public pure override(IGovernorUpgradeable) returns (uint256) {
        return 15 minutes; // 1 block
    }

    function votingPeriod() public pure override(IGovernorUpgradeable) returns (uint256) {
        return 1 weeks;
    }

    function setTeam(address newTeam) external {
        require(msg.sender == team, "not team");
        team = newTeam;
    }

    function setProposalNumerator(uint256 numerator) external {
        require(msg.sender == team, "not team");
        require(numerator <= MAX_PROPOSAL_NUMERATOR, "numerator too high");
        proposalNumerator = numerator;
    }

    function proposalThreshold()
        public
        view
        override(L2Governor)
        returns (uint256)
    {
        return
            (token.getPastTotalSupply(block.timestamp) * proposalNumerator) /
            PROPOSAL_DENOMINATOR;
    }
}
