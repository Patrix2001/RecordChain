# Implementation of Registration of Certificate Course using Ethereum Smart Contract

This project adapts from the [Kartu Prakerja](https://www.prakerja.go.id).

Kartu Prakerja is a semi-social assistance program for fresh graduates, job seekers, and lay-off workers to get training in skills development and entrepreneurship.

#### Problems in Existing System

- Manually validating participant data and checking certificates which are time-consuming, data manipulation, and data loss.

- Blockchain can solve this by providing an immutable and verifiable data source to generate a Proof-of-Existence, Proof-Authenticity & Proof-of-Integrity of a certificate on Blockchain.

#### What we are providing?

- We have implemented smart contract addressing the issue of storing course data and certificate data verified by various parties in the blockchain.

#### Use Case Diagram
![architecture-Page-16](https://user-images.githubusercontent.com/61679822/204191998-f672698d-8915-44da-8ab5-c90761f697df.png)


**Owner** : as a deployer of the smart contract, adds users and becomes a funder to finance courses for learners.

**Trainer** : The trainer provides course services that can create courses, update courses, and certify learners according to the courses listed.

**Learner** : Learners can register for courses, receive verifiable certificates, and reimburse the course fees if they cannot finish the course.

#### How it works

1. Deploy storage contract.
2. Copy address of deployed storage contract.
3. Deploy User, Course, Certificate, and Transaction contract with storage contract address.
4. You can fill balance on Transaction of smart contract.
5. Now our contract is ready.

#### Usage

- `updateUser` : creates/updates a user and fires `UpdateUser` event.
- `createCourse` : creates a course and fires `UpdateCourse` event.
- `createTransaction` : deploys smart contract of Transaction including `value`.
- `sendCredit` : sends reward to learner and pay the course with `value` of owner.
- `requestCredit` : sends back `value` to owner
- `payCourse` : sends value from learner to course of trainer
- `issueCertificate` : certifies Learner on the course
- `proofCertificate` : check certificate based on storage and address of the learner.
