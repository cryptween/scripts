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
  console.log('    npx cryptween my-app');
  console.log('    OR');
  console.log('    npm init cryptween my-app');
  process.exit(1);
}

// Define constants
const ownPath = process.cwd();
const folderName = process.argv[2];
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

    // Delete .git folder
    await runCmd('npx rimraf ./.git');
    // Delete .cryptween test folder
    await runCmd('npx rimraf ./.cryptween');

    // Create binaries
    await runCmd('npm run build');

    // Remove extra files
    // fs.unlinkSync(path.join(appPath, 'CHANGELOG.md'));
    // fs.unlinkSync(path.join(appPath, 'CODE_OF_CONDUCT.md'));
    // fs.unlinkSync(path.join(appPath, 'CONTRIBUTING.md'));
    fs.unlinkSync(path.join(appPath, 'bin', 'createNodejsApp.js'));
    fs.rmdirSync(path.join(appPath, 'bin'));
    if (!useYarn) {
      fs.unlinkSync(path.join(appPath, 'yarn.lock'));
    }

    console.log('Installation is now complete!');
    console.log();

    console.log('We suggest that you start by typing:');
    console.log(`    cd ${folderName}`);
    console.log(useYarn ? '    yarn dev' : '    npm run dev');
    console.log();
    console.log('Enjoy your production-ready Node.js app, which already supports a large number of ready-made features!');
    console.log('Check README.md for more info.');
  } catch (error) {
    console.log(error);
  }
}

setup();