## Contracts

### MembershipManager

userSignup(%{ email, pass }, role \\ student)
tempUserSignup(email, role \\ student) # creates user with default pass, has to be changed.

requestInstitutionStatus(student_email)
pendingInstitutions()

addProfessorToInstitution(student_email, institutionId)
enrollstudentInProfessorSubject(student_email, subject_id)

acceptInstitutionRequest(institutionId)
denyInstitutionRequest(institution_id, reason)
acceptProfessorshipRequest(student_email, institution_id)
denyProfessorshipRequest(student_email, institution_id, reason)
acceptEnrollmentRequest(student_email, subject_id)
denyEnrollmentRequest(student_email, subject_id, reason)

### ContentManager

submitsubject(subjectStruct)
publishsubject(subjectId)
unPublishsubject(subjectId)

enrollstudentInSubject(student_email, subject_id, payment_details \\ %{})

getNextContentBlock(student_email, subject_id)
getNextReviewBlock(leaner_email)

consumeContentBlock(student_email, subject_id, content_block_id, answerStruct)
previewContentBlock(contentBlockStruct) <- needs arch, essentially just allows us to preview a content block without persisting it, useful for editing. ->
 
buildRevisionQueues()

### Authorization Utility

newUser(email, pass, role)
changeRole(email, pass, role)

### User Property Access

setstudentProperties(email, %{ student_props })
createInstitution(student_email, %{ institution_props })

pendingInstitutions()
acceptInstitutionRequest(institution_id)
denyInstitutionRequest(institution_id, reason)

acceptProfessorshipRequest(student_email, institution_id)
denyProfessorshipRequest(student_email, institution_id, reason)

getInstitutionDomainName(institution_id)

### Credential Access

newUser(email, pass, role)
changeRole(email, new_role)

### User Progression Access

enrollstudent(student_email, subject_id)
unenrollstudent(student_email, subect_id)
retrieveProgression(student_email, subject_id)
saveProgression(student_email, subject_id, consumed_blocks)

### subject Access

save(student_email, subjectStruct)
publish(student_email, subject_id)
unPublish(student_email, subject_id)
fetchSoFar(student_email, subject_id)
fetchContentBlock(subject_id, content_block_id)
