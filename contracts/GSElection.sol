pragma solidity 0.8.18;

contract GSElection {
    // Define the data structure for a candidate
    struct Candidate {
        string name;
        uint256 voteCount;
    }

    // Define the data structure for a user
    struct User {
        address userAddress;
        bool isAdmin;
        bool hasVoted; // New field to track whether the user has voted
    }

    // Define the candidates array
    Candidate[] public candidates;

    // Define the users mapping
    mapping(address => User) public users;

    // Define the current round
    uint256 public currentRound;

    // Define the event for when a candidate is added
    event CandidateAdded(uint256 indexed candidateId, string candidateName);

    // Define the event for when a user is added
    event UserAdded(address indexed userAddress, bool isAdmin);

    // Define the event for when a user votes
    event Voted(address indexed userAddress, uint256 indexed candidateId);

    // Admin address
    address public admin;

    // Constructor to set the admin
    constructor() {
        admin = msg.sender;
    }

    // Modifier to restrict access to only admin
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this function");
        _;
    }

    // Add a candidate to the candidates array
    function addCandidate(string memory _candidateName) public onlyAdmin {
        candidates.push(Candidate(_candidateName, 0));
        emit CandidateAdded(candidates.length - 1, _candidateName);
    }

    // Add a user to the users mapping
    function addUser(address _userAddress, bool _isAdmin) public onlyAdmin {
        users[_userAddress] = User(_userAddress, _isAdmin, false); // Set hasVoted to false by default
        emit UserAdded(_userAddress, _isAdmin);
    }

    // Allow a user to vote for a candidate
    function vote(uint256 _candidateId) public {
        address userAddress = msg.sender;
        require(!users[userAddress].isAdmin, "Admins cannot vote");
        require(!users[userAddress].hasVoted, "User has already voted");
        require(_candidateId < candidates.length, "Invalid candidate ID");

        candidates[_candidateId].voteCount++;
        users[userAddress].hasVoted = true;
        emit Voted(userAddress, _candidateId);
    }

    // Get the name of a candidate
    function getCandidateName(uint256 _candidateId) public view returns (string memory) {
        require(_candidateId < candidates.length, "Invalid candidate ID");
        return candidates[_candidateId].name;
    }

    // Get the vote count of a candidate
    function getCandidateVoteCount(uint256 _candidateId) public view returns (uint256) {
        require(_candidateId < candidates.length, "Invalid candidate ID");
        return candidates[_candidateId].voteCount;
    }

    // Get the number of candidates
    function getNumCandidates() public view returns (uint256) {
        return candidates.length;
    }

    // Check if the user has voted
    function hasUserVoted(address _userAddress) public view returns (bool) {
        return users[_userAddress].hasVoted;
    }
}
