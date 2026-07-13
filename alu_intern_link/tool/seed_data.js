// One-off script to fill Firestore + Firebase Auth with realistic test
// data, so the app has something to look at without manually signing up
// a dozen accounts by hand.
//
// Uses the Firebase Admin SDK, which authenticates with a service account
// key instead of a user login, and (unlike the app itself) is NOT subject
// to firestore.rules - it can write any document directly. That's exactly
// what we want here: e.g. creating a startup that's already "verified"
// without having to go through the real admin-approval flow first.
//
// Setup:
//   1. Firebase Console > Project settings > Service accounts >
//      "Generate new private key" - save the downloaded file as
//      tool/serviceAccountKey.json (gitignored, never commit it).
//   2. cd tool && npm install
//   3. npm run seed
//
// Safe to re-run: existing auth users/startups are looked up by
// email/name instead of duplicated.

// firebase-admin v14 uses the same "modular" import style as the newer
// client SDKs - top-level `require('firebase-admin')` no longer carries
// .credential/.auth()/.firestore(), those live in their own submodules.
const { initializeApp, cert } = require('firebase-admin/app');
const { getAuth } = require('firebase-admin/auth');
const { getFirestore, FieldValue } = require('firebase-admin/firestore');
const serviceAccount = require('./serviceAccountKey.json');

initializeApp({ credential: cert(serviceAccount) });

const auth = getAuth();
const db = getFirestore();
const PASSWORD = 'Password123!';

async function getOrCreateUser(email, displayName) {
  try {
    const existing = await auth.getUserByEmail(email);
    return existing.uid;
  } catch {
    const created = await auth.createUser({ email, password: PASSWORD, displayName });
    return created.uid;
  }
}

async function setUserDoc(uid, data) {
  await db
    .collection('users')
    .doc(uid)
    .set(
      { onboardingComplete: true, createdAt: FieldValue.serverTimestamp(), ...data },
      { merge: true },
    );
}

async function findStartupByName(name) {
  const snapshot = await db.collection('startups').where('name', '==', name).limit(1).get();
  return snapshot.empty ? null : snapshot.docs[0].id;
}

async function createStartupIfMissing(data) {
  const existingId = await findStartupByName(data.name);
  if (existingId) return existingId;

  const ref = db.collection('startups').doc();
  await ref.set({ createdAt: FieldValue.serverTimestamp(), ...data });
  return ref.id;
}

async function findOpportunityByTitle(title, startupId) {
  const snapshot = await db
    .collection('opportunities')
    .where('title', '==', title)
    .where('startupId', '==', startupId)
    .limit(1)
    .get();
  return snapshot.empty ? null : snapshot.docs[0].id;
}

async function createOpportunityIfMissing(data) {
  const existingId = await findOpportunityByTitle(data.title, data.startupId);
  if (existingId) return existingId;

  const ref = db.collection('opportunities').doc();
  await ref.set({ status: 'open', createdAt: FieldValue.serverTimestamp(), ...data });
  return ref.id;
}

async function createApplicationIfMissing(data) {
  const snapshot = await db
    .collection('applications')
    .where('opportunityId', '==', data.opportunityId)
    .where('studentUid', '==', data.studentUid)
    .limit(1)
    .get();
  if (!snapshot.empty) return;

  await db
    .collection('applications')
    .doc()
    .set({ createdAt: FieldValue.serverTimestamp(), ...data });
}

async function createBookmark(studentUid, opportunityId, opportunityTitle, startupName) {
  const id = `${studentUid}_${opportunityId}`;
  await db
    .collection('bookmarks')
    .doc(id)
    .set({
      studentUid,
      opportunityId,
      opportunityTitle,
      startupName,
      createdAt: FieldValue.serverTimestamp(),
    });
}

async function main() {
  console.log('Creating auth users...');
  const aminaUid = await getOrCreateUser('student1@alustudent.com', 'Amina Hassan');
  const kwameUid = await getOrCreateUser('student2@alustudent.com', 'Kwame Mensah');
  const niaUid = await getOrCreateUser('founder1@alustudent.com', 'Nia Okafor');
  const tariqUid = await getOrCreateUser('founder2@alustudent.com', 'Tariq Ali');
  const zolaUid = await getOrCreateUser('founder3@alustudent.com', 'Zola Ndlovu');
  const samUid = await getOrCreateUser('founder4@alustudent.com', 'Sam Kariuki');
  const adminUid = await getOrCreateUser('admin1@alustudent.com', 'ALU Admin');

  console.log('Writing user profile documents...');
  await setUserDoc(aminaUid, {
    email: 'student1@alustudent.com',
    fullName: 'Amina Hassan',
    role: 'student',
    bio: 'Software Engineering student who loves building mobile apps.',
    skills: ['Flutter', 'Dart', 'UI Design'],
  });
  await setUserDoc(kwameUid, {
    email: 'student2@alustudent.com',
    fullName: 'Kwame Mensah',
    role: 'student',
    bio: 'Aspiring backend engineer, into distributed systems.',
    skills: ['Node.js', 'Python', 'Firestore'],
  });
  await setUserDoc(niaUid, {
    email: 'founder1@alustudent.com',
    fullName: 'Nia Okafor',
    role: 'startup',
    bio: 'Founder of EduBridge.',
  });
  await setUserDoc(tariqUid, {
    email: 'founder2@alustudent.com',
    fullName: 'Tariq Ali',
    role: 'startup',
    bio: 'Founder of GreenLoop.',
  });
  await setUserDoc(zolaUid, {
    email: 'founder3@alustudent.com',
    fullName: 'Zola Ndlovu',
    role: 'startup',
    bio: 'Founder of QuickCash.',
  });
  await setUserDoc(samUid, {
    email: 'founder4@alustudent.com',
    fullName: 'Sam Kariuki',
    role: 'startup',
    bio: 'Founder of Learnify.',
  });
  await setUserDoc(adminUid, { email: 'admin1@alustudent.com', fullName: 'ALU Admin', role: 'admin' });

  console.log('Creating startups...');
  const eduBridgeId = await createStartupIfMissing({
    name: 'EduBridge',
    industry: 'EdTech',
    ownerUid: niaUid,
    status: 'verified',
    description: 'Connecting underserved students with quality learning resources across Africa.',
    website: 'https://edubridge.example.com',
  });
  const learnifyId = await createStartupIfMissing({
    name: 'Learnify',
    industry: 'EdTech',
    ownerUid: samUid,
    status: 'verified',
    description: 'A peer-to-peer tutoring marketplace for university students.',
    website: 'https://learnify.example.com',
  });
  await createStartupIfMissing({
    name: 'GreenLoop',
    industry: 'Sustainability',
    ownerUid: tariqUid,
    status: 'pending',
    description: 'Campus composting and recycling logistics startup.',
  });
  await createStartupIfMissing({
    name: 'QuickCash',
    industry: 'FinTech',
    ownerUid: zolaUid,
    status: 'rejected',
    description: 'Peer-to-peer micro-lending app for students.',
  });

  console.log('Creating opportunities...');
  const flutterDevId = await createOpportunityIfMissing({
    startupId: eduBridgeId,
    startupName: 'EduBridge',
    postedByUid: niaUid,
    title: 'Flutter Developer',
    category: 'softwareDevelopment',
    location: 'onCampus',
    description: 'Help us build the mobile app for our learning platform. You will work on real features and UI.',
    skillsRequired: ['Flutter', 'Dart', 'Firebase'],
  });
  const uxResearchId = await createOpportunityIfMissing({
    startupId: eduBridgeId,
    startupName: 'EduBridge',
    postedByUid: niaUid,
    title: 'UX Research Volunteer',
    category: 'design',
    location: 'remote',
    description: 'Run user interviews and usability tests with students to improve our onboarding flow.',
    skillsRequired: ['UX Design', 'Research'],
  });
  const socialMediaId = await createOpportunityIfMissing({
    startupId: learnifyId,
    startupName: 'Learnify',
    postedByUid: samUid,
    title: 'Social Media Assistant',
    category: 'marketing',
    location: 'hybrid',
    description: 'Plan and post content across Instagram and TikTok to grow our student audience.',
    skillsRequired: ['Content Creation', 'Canva'],
  });
  const backendInternId = await createOpportunityIfMissing({
    startupId: learnifyId,
    startupName: 'Learnify',
    postedByUid: samUid,
    title: 'Backend Engineer Intern',
    category: 'softwareDevelopment',
    location: 'remote',
    description: 'Build and maintain Firestore-backed APIs powering our tutor-matching engine.',
    skillsRequired: ['Node.js', 'Firestore'],
  });
  const communityMgrId = await createOpportunityIfMissing({
    startupId: learnifyId,
    startupName: 'Learnify',
    postedByUid: samUid,
    title: 'Community Manager',
    category: 'communityManagement',
    location: 'onCampus',
    description: 'Grow and moderate our student Discord community of 500+ tutors and learners.',
    skillsRequired: ['Communication', 'Discord'],
  });

  console.log('Creating applications...');
  await createApplicationIfMissing({
    opportunityId: flutterDevId,
    opportunityTitle: 'Flutter Developer',
    startupId: eduBridgeId,
    startupName: 'EduBridge',
    studentUid: aminaUid,
    studentName: 'Amina Hassan',
    studentEmail: 'student1@alustudent.com',
    coverNote: "I've built two Flutter apps for coursework and would love to bring that experience to EduBridge.",
    status: 'reviewed',
  });
  await createApplicationIfMissing({
    opportunityId: socialMediaId,
    opportunityTitle: 'Social Media Assistant',
    startupId: learnifyId,
    startupName: 'Learnify',
    studentUid: aminaUid,
    studentName: 'Amina Hassan',
    studentEmail: 'student1@alustudent.com',
    coverNote: "I run our hall's Instagram page and grew it from 50 to 800 followers this year.",
    status: 'pending',
  });
  await createApplicationIfMissing({
    opportunityId: flutterDevId,
    opportunityTitle: 'Flutter Developer',
    startupId: eduBridgeId,
    startupName: 'EduBridge',
    studentUid: kwameUid,
    studentName: 'Kwame Mensah',
    studentEmail: 'student2@alustudent.com',
    coverNote: 'Backend-leaning but comfortable in Dart - keen to round out my mobile skills.',
    status: 'accepted',
  });
  await createApplicationIfMissing({
    opportunityId: backendInternId,
    opportunityTitle: 'Backend Engineer Intern',
    startupId: learnifyId,
    startupName: 'Learnify',
    studentUid: kwameUid,
    studentName: 'Kwame Mensah',
    studentEmail: 'student2@alustudent.com',
    coverNote: 'I have built REST APIs with Node and Firestore for two class projects.',
    status: 'pending',
  });

  console.log('Creating bookmarks...');
  await createBookmark(aminaUid, backendInternId, 'Backend Engineer Intern', 'Learnify');
  await createBookmark(aminaUid, communityMgrId, 'Community Manager', 'Learnify');
  await createBookmark(kwameUid, uxResearchId, 'UX Research Volunteer', 'EduBridge');

  console.log('\nDone. Test accounts (all share the same password):');
  console.log(`  Password: ${PASSWORD}`);
  console.log('  student1@alustudent.com  Amina Hassan   - student');
  console.log('  student2@alustudent.com  Kwame Mensah   - student');
  console.log('  founder1@alustudent.com  Nia Okafor     - owns EduBridge  (VERIFIED)');
  console.log('  founder4@alustudent.com  Sam Kariuki    - owns Learnify   (VERIFIED)');
  console.log('  founder2@alustudent.com  Tariq Ali      - owns GreenLoop  (PENDING)');
  console.log('  founder3@alustudent.com  Zola Ndlovu    - owns QuickCash  (REJECTED)');
  console.log('  admin1@alustudent.com    ALU Admin      - can verify/reject startups');
}

main()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error(err);
    process.exit(1);
  });
