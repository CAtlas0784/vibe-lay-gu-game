"use strict";

const fs = require("fs");
const path = require("path");

const projectRoot = path.resolve(process.env.Ananta_ROOT || path.resolve(__dirname, "..", ".."));
const configPath = path.resolve(process.env.Ananta_CONFIG || path.join(projectRoot, "config", "private-server.json"));

function fail(message) {
  throw new Error(`[CONFIG] ${message} (${configPath})`);
}

function requireObject(value, name) {
  if (!value || typeof value !== "object" || Array.isArray(value)) fail(`missing or invalid section '${name}'`);
  return value;
}

function requireText(value, name) {
  if (typeof value !== "string" || value.trim() === "") fail(`${name} must not be empty`);
}

function requirePositiveInteger(value, name) {
  if (!Number.isSafeInteger(value) || value <= 0) fail(`${name} must be a positive safe integer`);
}

function requirePort(value, name) {
  if (!Number.isInteger(value) || value < 1 || value > 65535) fail(`${name} must be 1..65535, got '${value}'`);
}

function readConfig() {
  if (!fs.existsSync(configPath)) fail("private-server.json not found");

  let value;
  try {
    value = JSON.parse(fs.readFileSync(configPath, "utf8").replace(/^\uFEFF/, ""));
  } catch (error) {
    fail(`invalid JSON: ${error.message}`);
  }

  const client = requireObject(value.client, "client");
  const network = requireObject(value.network, "network");
  const proxy = requireObject(network.proxy, "network.proxy");
  const player = requireObject(value.player, "player");
  const world = requireObject(value.world, "world");
  const content = requireObject(value.content, "content");
  const roster = requireObject(content.roster, "content.roster");
  const gameplay = requireObject(value.gameplay, "gameplay");
  const combat = requireObject(gameplay.combat, "gameplay.combat");
  const skills = requireObject(combat.skills, "gameplay.combat.skills");
  const web = requireObject(gameplay.webTraversal, "gameplay.webTraversal");
  const ui = requireObject(value.ui, "ui");
  const paths = requireObject(value.paths, "paths");

  requirePositiveInteger(client.version, "client.version");
  const supportedClientVersions = [4229938];
  if (!supportedClientVersions.includes(client.version))
    fail(`client.version=${client.version} is not supported by this source tree; expected one of ${supportedClientVersions.join(", ")}`);
  requirePositiveInteger(client.serverId, "client.serverId");
  requireText(client.rpcMd5, "client.rpcMd5");
  requireText(network.bindHost, "network.bindHost");
  requireText(network.advertisedHost, "network.advertisedHost");

  if (!Array.isArray(network.loginPorts) || network.loginPorts.length !== 2)
    fail("network.loginPorts must contain exactly two ports");
  network.loginPorts.forEach((port, i) => requirePort(port, `network.loginPorts[${i}]`));
  requirePort(network.gamePort, "network.gamePort");
  for (const name of ["httpsPort", "httpPort", "loginListPort", "loginTcpPort", "gameTcpPort", "sceneSubPort"])
    requirePort(proxy[name], `network.proxy.${name}`);
  requireText(proxy.updateHost, "network.proxy.updateHost");
  requireText(proxy.certificatePassphrase, "network.proxy.certificatePassphrase");

  requirePositiveInteger(player.pid, "player.pid");
  requirePositiveInteger(player.initialUnitId, "player.initialUnitId");
  requirePositiveInteger(player.initialSpiritTemplateId, "player.initialSpiritTemplateId");
  for (const name of ["accountId", "userName", "displayName", "loginToken", "gameToken", "shareToken", "fpPassToken", "skey"])
    requireText(player[name], `player.${name}`);

  requirePositiveInteger(world.raidId, "world.raidId");
  requirePositiveInteger(world.sceneInstanceId, "world.sceneInstanceId");
  requirePositiveInteger(world.universeId, "world.universeId");
  const spawn = requireObject(world.spawn, "world.spawn");
  for (const axis of ["x", "y", "z"]) if (!Number.isFinite(spawn[axis])) fail(`world.spawn.${axis} must be a finite number`);

  requirePositiveInteger(roster.templateIdMin, "content.roster.templateIdMin");
  requirePositiveInteger(roster.templateIdMaxExclusive, "content.roster.templateIdMaxExclusive");
  if (roster.templateIdMin >= roster.templateIdMaxExclusive)
    fail("content.roster.templateIdMin must be less than templateIdMaxExclusive");
  requirePositiveInteger(roster.unitIdBase, "content.roster.unitIdBase");

  if (!Number.isFinite(combat.maxHp) || combat.maxHp <= 0) fail("gameplay.combat.maxHp must be positive");
  const skillNames = ["common", "pressCommon", "heavyCommon", "dodge", "dodgeAttack", "grappleAttack", "active", "unique"];
  for (const name of skillNames) requirePositiveInteger(skills[name], `gameplay.combat.skills.${name}`);
  if (!Array.isArray(combat.charges) || combat.charges.length === 0) fail("gameplay.combat.charges must not be empty");
  const chargeNames = new Set(skillNames.map(x => x.toLowerCase()));
  for (const [i, charge] of combat.charges.entries()) {
    if (!charge || typeof charge !== "object") fail(`gameplay.combat.charges[${i}] must be an object`);
    if (typeof charge.skill !== "string" || !chargeNames.has(charge.skill.toLowerCase()))
      fail(`gameplay.combat.charges[${i}].skill is unknown: '${charge.skill}'`);
    if (!Number.isInteger(charge.max) || charge.max <= 0 || !Number.isInteger(charge.current) || charge.current < 0 || charge.current > charge.max)
      fail(`gameplay.combat.charges[${i}] has invalid current/max`);
    if (!Number.isFinite(charge.period) || charge.period < 0) fail(`gameplay.combat.charges[${i}].period must be >= 0`);
  }

  if (!Array.isArray(web.sharedBuffIds) || web.sharedBuffIds.length === 0) fail("gameplay.webTraversal.sharedBuffIds must not be empty");
  requirePositiveInteger(web.persistentGrappleBuffId, "gameplay.webTraversal.persistentGrappleBuffId");
  if (!web.sharedBuffIds.includes(web.persistentGrappleBuffId))
    fail("gameplay.webTraversal.persistentGrappleBuffId must also be in sharedBuffIds");

  const uidLabel = requireObject(ui.uidLabel, "ui.uidLabel");
  if (typeof uidLabel.enabled !== "boolean") fail("ui.uidLabel.enabled must be boolean");
  if (uidLabel.enabled) requireText(uidLabel.text, "ui.uidLabel.text");
  if (typeof ui.removeStockConfidentialLabel !== "boolean") fail("ui.removeStockConfidentialLabel must be boolean");
  requireText(paths.clientConfigs, "paths.clientConfigs");
  requireText(paths.runtimeFastpatch, "paths.runtimeFastpatch");
  return value;
}

const config = readConfig();

function resolveProjectPath(configuredPath) {
  if (!configuredPath) return projectRoot;
  return path.isAbsolute(configuredPath)
    ? path.normalize(configuredPath)
    : path.resolve(projectRoot, configuredPath);
}

module.exports = { config, configPath, projectRoot, resolveProjectPath };
