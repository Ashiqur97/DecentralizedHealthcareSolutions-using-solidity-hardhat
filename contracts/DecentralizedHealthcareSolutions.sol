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
        // Input validation
        require(bytes(_recordHash).length > 0, "Record hash cannot be empty.");

        // Increment the medical record count
        medicalRecordCount++;

        // Add the medical record to the mapping
        medicalRecords[medicalRecordCount] = MedicalRecord({
            recordId: medicalRecordCount,
            recordHash: _recordHash,
            timestamp: block.timestamp
        });

        // Add the record hash to the patient's record list
        patients[msg.sender].medicalRecordHashes.push(_recordHash);

        // Emit the RecordAdded event
        emit RecordAdded(medicalRecordCount, msg.sender, _recordHash);
    }

    function grantConsent(address _entity) external onlyRegisteredPatients {
        require(_entity != address(0), "Invalid entity address.");
        consents[msg.sender][_entity] = true;
        emit ConsentGranted(msg.sender, _entity);
    }

        function registerDoctor(string memory _name, string memory _specialization) external {
        // Input validation
        require(bytes(_name).length > 0, "Name cannot be empty.");
        require(bytes(_specialization).length > 0, "Specialization cannot be empty.");

        // Ensure the doctor is not already registered
        require(!doctors[msg.sender].isRegistered, "Doctor already registered.");

        // Initialize the doctor struct
        doctors[msg.sender] = Doctor({
            doctorAddress: msg.sender,
            name: _name,
            specialization: _specialization,
            isRegistered: true,
            isApproved: false,
            isBanned: false,
            referralBonus: 0
        });

        // Emit the DoctorRegistered event
        emit DoctorRegistered(msg.sender, _name, _specialization);
    }

       function approveDoctor(address _doctorAddress) external onlyAdmin {
        // Input validation
        require(_doctorAddress != address(0), "Invalid doctor address.");

        // Ensure the doctor is registered
        require(doctors[_doctorAddress].isRegistered, "Doctor is not registered.");

        // Approve the doctor
        doctors[_doctorAddress].isApproved = true;
    }

        function referPatient(address _patientAddress, address _specialist) external onlyRegisteredDoctors {
        // Input validation
        require(_patientAddress != address(0), "Invalid patient address.");
        require(_specialist != address(0), "Invalid specialist address.");

        // Ensure the patient is registered
        require(patients[_patientAddress].isRegistered, "Patient is not registered.");

        // Ensure the specialist is registered and approved
        require(doctors[_specialist].isRegistered && doctors[_specialist].isApproved, "Specialist is not approved.");

        // Grant consent to the specialist
        consents[_patientAddress][_specialist] = true;

        // Reward the referring doctor
        doctors[msg.sender].referralBonus += 10;

        // Emit the ConsentGranted event
        emit ConsentGranted(_patientAddress, _specialist);
    }

      function triggerEmergencyProtocol(address _patientAddress, uint256 _duration) external onlyAdmin noReentrancy {
        // Input validation
        require(_patientAddress != address(0), "Invalid patient address.");
        require(_duration > 0, "Duration must be greater than zero.");

        // Ensure the patient is registered
        require(patients[_patientAddress].isRegistered, "Patient is not registered.");

        // Activate the emergency protocol
        emergencyProtocols[_patientAddress] = EmergencyProtocol({
            patientAddress: _patientAddress,
            responder: msg.sender,
            startTime: block.timestamp,
            endTime: block.timestamp + _duration,
            isActive: true
        });

        // Emit the EmergencyAccessGranted event
        emit EmergencyAccessGranted(_patientAddress, msg.sender);
    }

 function registerInsurancePolicy(uint256 _coverageAmount) external onlyRegisteredPatients noReentrancy {
        // Input validation
        require(_coverageAmount > 0, "Coverage amount must be greater than zero.");

        // Ensure the patient does not already have an active policy
        require(!insurancePolicies[msg.sender].isActive, "Insurance policy already registered.");

        // Register the insurance policy
        insurancePolicies[msg.sender] = InsurancePolicy({
            policyId: uint256(keccak256(abi.encodePacked(msg.sender, block.timestamp))),
            insurer: msg.sender,
            coverageAmount: _coverageAmount,
            claimableAmount: 0,
            isActive: true
        });

        // Emit the InsurancePolicyRegistered event
        emit InsurancePolicyRegistered(msg.sender, insurancePolicies[msg.sender].policyId, _coverageAmount);
    }

    function processInsuranceClaim(uint256 _amount) external onlyRegisteredPatients noReentrancy {
        // Input validation
        require(_amount > 0, "Claim amount must be greater than zero.");

        // Get the insurance policy
        InsurancePolicy storage policy = insurancePolicies[msg.sender];

        // Ensure the policy is active
        require(policy.isActive, "Insurance policy is not active.");

        // Ensure the claim amount does not exceed the coverage
        require(_amount <= policy.coverageAmount, "Claim amount exceeds coverage.");

        // Process the claim
        policy.claimableAmount += _amount;

        // Emit the ClaimProcessed event
        emit ClaimProcessed(msg.sender, _amount);
    }

    function createSupplyChainItem(string memory _itemName, uint256 _expirationDate) external {
          require(bytes(_itemName).length > 0, "Item name cannot be empty.");
        require(_expirationDate > block.timestamp, "Invalid expiration date");

        supplyChainItemCount++;

        supplyChainItems[supplyChainItemCount] = SupplyChainItem({
            itemId: supplyChainItemCount,
            itemName: _itemName,
            manufacturer:msg.sender,
            currentOwner:msg.sender,
            expirationDate:_expirationDate,
            isDelivered:false
        });
        
          emit SupplyChainItemCreated(supplyChainItemCount , _itemName, msg.sender);

    }


    function transferSupplyChainItem(uint256 _itemId, address _newOwner) external {
        // Input validation
        require(_newOwner != address(0), "Invalid new owner address.");

        // Get the supply chain item
        SupplyChainItem storage item = supplyChainItems[_itemId];

        // Ensure the item exists
        require(item.itemId > 0, "Invalid item ID.");

        // Ensure the sender is the current owner
        require(item.currentOwner == msg.sender, "You do not own this item.");

        // Transfer ownership
        item.currentOwner = _newOwner;

        // Mark as delivered if the new owner is a patient
        if (_newOwner == patients[item.currentOwner].patientAddress) {
            item.isDelivered = true;
        }

        // Emit the SupplyChainItemTransferred event
        emit SupplyChainItemTransferred(_itemId, _newOwner);
    }

      function createProposal(string memory _description, uint256 _requestedFunding) external {
        // Input validation
        require(bytes(_description).length > 0, "Description cannot be empty.");
        require(_requestedFunding > 0, "Requested funding must be greater than zero.");

        // Increment the proposal count
        proposalCount++;

        // Create the proposal
        proposals[proposalCount] = Proposal({
            proposalId: proposalCount,
            proposer: msg.sender,
            description: _description,
            requestedFunding: _requestedFunding,
            fundsReceived: 0,
            isApproved: false
        });

        // Emit the ProposalCreated event
        emit ProposalCreated(proposalCount, msg.sender, _description, _requestedFunding);
    }

       function fundProposal(uint256 _proposalId) external payable noReentrancy {
        // Input validation
        require(_proposalId > 0, "Invalid proposal ID.");
        require(msg.value > 0, "You must send some funds.");

        // Get the proposal
        Proposal storage proposal = proposals[_proposalId];

        // Ensure the proposal exists
        require(proposal.proposalId > 0, "Invalid proposal ID.");

        // Add the funds to the proposal
        proposal.fundsReceived += msg.value;

        // Approve the proposal if funding goal is met
        if (proposal.fundsReceived >= proposal.requestedFunding) {
            proposal.isApproved = true;
        }
    }

}