// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DecentralizedHealthcareSolutions {
    // Structs
    struct Patient {
        address patientAddress;
        string name;
        uint256 age;
        string gender;
        bool isRegistered;
        bool isBanned;
        string[] medicalRecordHashes; // Off-chain encrypted hashes
    }

    struct Doctor {
        address doctorAddress;
        string name;
        string specialization;
        bool isRegistered;
        bool isApproved; // Admin approval required
        bool isBanned;
        uint256 referralBonus; // Referral bonuses in tokens
    }

    struct MedicalRecord {
        uint256 recordId;
        string recordHash; // Encrypted hash stored on-chain
        uint256 timestamp;
    }

    struct InsurancePolicy {
        uint256 policyId;
        address insurer;
        uint256 coverageAmount;
        uint256 claimableAmount;
        bool isActive;
    }

    struct TelemedicineConsultation {
        uint256 consultationId;
        address patient;
        address doctor;
        string notes;
        uint256 timestamp;
        uint256 fee;
        bool isPaid;
    }

    struct SupplyChainItem {
        uint256 itemId;
        string itemName;
        address manufacturer;
        address currentOwner;
        uint256 expirationDate; // Timestamp for expiration
        bool isDelivered;
    }

    struct Proposal {
        uint256 proposalId;
        address proposer;
        string description;
        uint256 requestedFunding;
        uint256 fundsReceived;
        bool isApproved;
    }

    struct Dispute {
        uint256 disputeId;
        address complainant;
        address respondent;
        string description;
        bool isResolved;
    }

    struct EmergencyProtocol {
        address patientAddress;
        address responder; // Hospital or emergency responder
        uint256 startTime;
        uint256 endTime; // Time-limited access
        bool isActive;
    }

    // Token for Rewards
    mapping(address => uint256) public rewardsBalance;

    // Mappings
    mapping(address => Patient) public patients;
    mapping(address => mapping(address => bool)) public consents; // Separate mapping for consents
    mapping(address => Doctor) public doctors;
    mapping(uint256 => MedicalRecord) public medicalRecords;
    mapping(address => InsurancePolicy) public insurancePolicies;
    mapping(uint256 => TelemedicineConsultation) public consultations;
    mapping(uint256 => SupplyChainItem) public supplyChainItems;
    mapping(uint256 => Proposal) public proposals;
    mapping(uint256 => Dispute) public disputes;
    mapping(address => EmergencyProtocol) public emergencyProtocols;

    uint256 public medicalRecordCount;
    uint256 public consultationCount;
    uint256 public supplyChainItemCount;
    uint256 public proposalCount;
    uint256 public disputeCount;

    // Admin Role
    address public admin;

    // Events
    event AdminSet(address indexed admin);
    event PatientRegistered(address indexed patientAddress, string name);
    event DoctorRegistered(address indexed doctorAddress, string name, string specialization);
    event RecordAdded(uint256 indexed recordId, address indexed patientAddress, string recordHash);
    event ConsentGranted(address indexed patientAddress, address indexed entity);
    event EmergencyAccessGranted(address indexed patientAddress, address indexed hospital);

    event InsurancePolicyRegistered(address indexed patientAddress, uint256 policyId, uint256 coverageAmount);
    event ClaimProcessed(address indexed patientAddress, uint256 amountClaimed);

    event ConsultationCreated(uint256 indexed consultationId, address indexed patient, address indexed doctor);
    event ConsultationPaid(uint256 indexed consultationId, uint256 amount);

    event SupplyChainItemCreated(uint256 indexed itemId, string itemName, address manufacturer);
    event SupplyChainItemTransferred(uint256 indexed itemId, address newOwner);

    event ProposalCreated(uint256 indexed proposalId, address indexed proposer, string description, uint256 requestedFunding);
    event DisputeRaised(uint256 indexed disputeId, address indexed complainant, address indexed respondent);
    event DisputeResolved(uint256 indexed disputeId);

    event TokensRewarded(address indexed recipient, uint256 amount);

    bool internal locked;

    modifier noReentrancy() {
        require(!locked,"Reentrant call detected");
        locked = true;
        _;
        locked = false;
    }

      modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action.");
        _;
    }

      modifier onlyRegisteredPatients() {
        require(patients[msg.sender].isRegistered && !patients[msg.sender].isBanned, "Only registered patients can perform this action.");
        _;
    }

    modifier onlyRegisteredDoctors() {
        require(doctors[msg.sender].isRegistered && doctors[msg.sender].isApproved && !doctors[msg.sender].isBanned, "Only approved doctors can perform this action.");
        _;
    }

    function registerPatient(string memory _name, uint256 _age, string memory _gender) external {
        require(bytes(_name).length > 0, "Name can not be empty");
        require(_age > 0 , "Age must be greater than zero");
        require(bytes(_gender).length > 0, "Gender cannot be empty");

        require(!patients[msg.sender].isRegistered, "Patient already registered");

        patients[msg.sender] = Patient({
            patientAddress: msg.sender,
            name:_name,
            age:_age,
            gender:_gender,
            isRegistered:true,
            isBanned:false,
            medicalRecordHashes: new string[](0)
        });

        emit PatientRegistered(msg.sender, _name);
    }

       function addMedicalRecord(string memory _recordHash) external onlyRegisteredPatients {
      
        require(bytes(_recordHash).length > 0, "Record hash cannot be empty.");

       
        medicalRecordCount++;

       
        medicalRecords[medicalRecordCount] = MedicalRecord({
            recordId: medicalRecordCount,
            recordHash: _recordHash,
            timestamp: block.timestamp
        });

        
        patients[msg.sender].medicalRecordHashes.push(_recordHash);

      
        emit RecordAdded(medicalRecordCount, msg.sender, _recordHash);
    }
    
}