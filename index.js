// maa-dsh-skill — DSH 插件入口（以 npm / DSH Bundle 方式安装时加载的插件层）
//
// 安装方式：dsh plugin --profile <profile名> add maa-dsh-skill（或本地目录 / .tgz）
// 作用：
//   1) 启动时打印加载日志（验证插件层已生效）；
//   2) 把本包内的 SKILL.md 注册为「运行时技能」写入 ctx.skills 注册表，
//      使 AI 助手在会话中可直接加载该技能（资源目录指向包内目录）。
//      若同名技能已由其它来源（如 skill 发现根中的文件系统技能）提供，
//      注册会被注册表忽略 —— 文件系统方式优先，两者互不冲突。
import { readFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

export const name = "maa-dsh-skill";
export const inject = ["skills"];

const packageDir = dirname(fileURLToPath(import.meta.url));
const skillPath = join(packageDir, "SKILL.md");

/**
 * 读取包内 SKILL.md：提取 frontmatter 的 name / description / whenToUse，
 * 正文（frontmatter 之后、首尾去空白）作为技能内容。解析失败返回 null。
 */
function loadSkill() {
	const raw = readFileSync(skillPath, "utf8");
	const match = /^---\r?\n([\s\S]*?)\r?\n---\r?\n?/.exec(raw);
	if (!match) return null;
	const data = {};
	for (const line of match[1].split(/\r?\n/)) {
		const kv = /^\s*([A-Za-z_][A-Za-z0-9_-]*)\s*:\s*(.*?)\s*$/.exec(line);
		if (!kv || data[kv[1]] !== void 0) continue;
		let value = kv[2];
		if ((value.startsWith('"') && value.endsWith('"')) || (value.startsWith("'") && value.endsWith("'"))) {
			value = value.slice(1, -1);
		}
		data[kv[1]] = value;
	}
	if (typeof data.name !== "string" || data.name.length === 0) return null;
	if (typeof data.description !== "string" || data.description.length === 0) return null;
	return {
		name: data.name,
		description: data.description,
		whenToUse: typeof data.whenToUse === "string" && data.whenToUse.length > 0 ? data.whenToUse : void 0,
		content: raw.slice(match[0].length).trim()
	};
}

function log(...args) {
	try {
		console.log("[maa-dsh-skill]", ...args);
	} catch {
		/* 日志失败不影响插件运行 */
	}
}

export function apply(ctx) {
	log("Skill loaded!");
	let skill;
	try {
		skill = loadSkill();
	} catch (error) {
		log("failed to read SKILL.md:", error?.message ?? String(error));
	}
	if (!skill) {
		log("SKILL.md missing or without valid frontmatter — skill registration skipped");
		return;
	}
	const register = () => {
		const registry = ctx?.get?.("skills") ?? ctx?.skills;
		if (!registry || typeof registry.register !== "function") return false;
		try {
			registry.register({
				...skill,
				invocation: { modelInvocable: true, userInvocable: true },
				source: name,
				path: skillPath,
				resourceBase: { kind: "directory", path: packageDir }
			});
			log(`skill "${skill.name}" registered (from ${skillPath})`);
		} catch (error) {
			log("skill registration failed:", error?.message ?? String(error));
		}
		return true;
	};
	// inject 已声明依赖 skills 服务，正常情况下此处即就绪；兜底等待数秒再试一次。
	if (register()) return;
	let attempts = 0;
	const timer = setInterval(() => {
		attempts += 1;
		if (register() || attempts >= 20) clearInterval(timer);
	}, 500);
	try {
		timer.unref?.();
	} catch {
		/* 忽略 */
	}
}
