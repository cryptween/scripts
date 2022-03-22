#!/usr/bin/env node
const util = require('util');
const path = require('path');
const fs = require('fs');
const { execSync } = require('child_process');

// Utility functions
const exec = util.promisify(require('child_process').exec);
async function runCmd(command) {
  try {
    const { stdout, stderr } = await exec(command);
    console.log(stdout);
    console.log(stderr);
  } catch {
    (error) => {
      console.log(error);
    };
  }
}

function hasYarn() {
  try {
    execSync('yarnpkg --version', { stdio: 'ignore' });
    return true;
  } catch {
    return false;
  }
}

// Validate arguments
if (process.argv.length < 3) {
  console.log('Please specify the target project directory.');
  console.log('For example:');
  console.log('    node create-daemon-executables.js dist version');
  process.exit(1);
}

// Define constants
const ownPath = process.cwd();
const folderName = process.argv[2];
var version = ""
if (process.argv.length >= 3)
  version = process.argv[3];

const appPath = path.join(ownPath, folderName);
const appRepo = 'https://github.com/cryptween/cross-exchange-daemon.git';
const contractsRepo = 'https://github.com/cryptween/contracts.git';

// Check if directory already exists
try {
  fs.mkdirSync(appPath);
} catch (err) {
  if (err.code === 'EEXIST') {
    console.log('Directory already exists. Please choose another name for the project.');
  } else {
    console.log(error);
  }
  process.exit(1);
}

async function setup() {
  try {
    // Clone repo
    console.log(`Downloading files from application repo ${appRepo}`);
    await runCmd(`git clone --depth 1 ${appRepo} ${folderName}`);
    console.log('Application repository cloned successfully.');
    console.log('');

    // Change directory
    process.chdir(appPath);
    // Clone contracts repo
    console.log(`Downloading files from contracts repo ${contractsRepo}`);
    await runCmd(`git clone ${contractsRepo}`);
    console.log('Contracts repository cloned successfully.');
    console.log('');

    // Install dependencies
    const useYarn = hasYarn();
    console.log('Installing dependencies...');
    if (useYarn) {
      await runCmd('yarn install');
    } else {
      await runCmd('npm install');
    }
    console.log('Dependencies installed successfully.');
    console.log();

    // Copy envornment variables
    fs.copyFileSync(path.join(appPath, '.env.prod'), path.join(appPath, '.env'));
    console.log('Environment files copied.');

    // // Delete .git folder
    // await runCmd('npx rimraf ./.git');
    // Delete .cryptween test folder
    await runCmd('npx rimraf ./.cryptween');
    // Delete examples folder
    await runCmd('npx rimraf ./examples');
    // Delete test folder
    await runCmd('npx rimraf ./test');
    // Create binaries
    await runCmd('npm run build');

    // Remove extra files
    fs.unlinkSync(path.join(appPath, 'bin', 'createNodejsApp.js'));
    fs.rmdirSync(path.join(appPath, 'bin'));
    if (!useYarn) {
      fs.unlinkSync(path.join(appPath, 'yarn.lock'));
    }

    console.log(`Installation of version ${version} is now complete!`);
    console.log();

    if (version) {
      const generatedBinariesDir = path.join(appPath, 'dist')
      const generatedBinaryArray = fs.readdirSync(generatedBinariesDir)
      console.log('generated Binaries in ', generatedBinariesDir, generatedBinaryArray);

      const releaseCommand = `gh release create ${(version[0] == "v" ? version : "v" + version)} --generate-notes ${generatedBinariesDir}/*`
      console.log(releaseCommand)
      let res = await runCmd(releaseCommand);
      console.log(res)
      await runCmd(`git commit `);
      console.log('Application repository cloned successfully.');
      console.log('');
    }

    console.log('We suggest that you start by typing:');
    console.log(`    cd ${folderName}`);
    // console.log(useYarn ? '    yarn dev' : '    npm run dev');
    console.log();
    console.log('Enjoy your production-ready Node.js app, which already supports a large number of ready-made features!');
    console.log('Check README.md for more info.');
  } catch (error) {
    console.log(error);
  }
}

setup();