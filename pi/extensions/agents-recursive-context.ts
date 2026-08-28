import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { existsSync, readFileSync, realpathSync } from "node:fs";
import { homedir } from "node:os";
import { dirname, isAbsolute, join, relative } from "node:path";

type AgentsFile = {
  path: string;
  content: string;
};

export default function (pi: ExtensionAPI) {
  let agentsFiles: AgentsFile[] = [];

  pi.on("session_start", (_event, ctx) => {
    agentsFiles = [];

    try {
      const resolvedHome = realpathSync(homedir());
      const resolvedCwd = realpathSync(ctx.cwd);
      const cwdRelativeToHome = relative(resolvedHome, resolvedCwd);
      const cwdIsUnderHome =
        cwdRelativeToHome === "" || (!cwdRelativeToHome.startsWith("..") && !isAbsolute(cwdRelativeToHome));

      if (!cwdIsUnderHome) {
        return;
      }

      const discoveredAgentsFiles: AgentsFile[] = [];
      let currentDir = resolvedCwd;

      while (true) {
        const agentsPath = join(currentDir, "AGENTS.md");
        if (existsSync(agentsPath)) {
          try {
            discoveredAgentsFiles.push({
              path: realpathSync(agentsPath),
              content: readFileSync(agentsPath, "utf8"),
            });
          } catch {
            // Ignore unreadable AGENTS.md files and keep walking upward.
          }
        }

        if (currentDir === resolvedHome) {
          break;
        }

        const parentDir = dirname(currentDir);
        if (parentDir === currentDir) {
          break;
        }

        currentDir = parentDir;
      }

      agentsFiles = discoveredAgentsFiles.reverse();
    } catch {
      agentsFiles = [];
    }
  });

  pi.on("before_agent_start", (event) => {
    if (agentsFiles.length === 0) {
      return;
    }

    const loadedContextPaths = new Set<string>();
    for (const contextFile of event.systemPromptOptions.contextFiles ?? []) {
      try {
        loadedContextPaths.add(realpathSync(contextFile.path));
      } catch {
        loadedContextPaths.add(contextFile.path);
      }
    }

    const missingAgentsFiles = agentsFiles.filter((agentsFile) => !loadedContextPaths.has(agentsFile.path));
    if (missingAgentsFiles.length === 0) {
      return;
    }

    const projectInstructions = missingAgentsFiles
      .map((agentsFile) => {
        return `<project_instructions path="${agentsFile.path}">\n${agentsFile.content}\n</project_instructions>`;
      })
      .join("\n\n");

    return {
      systemPrompt: `${event.systemPrompt}\n\n<project_context>\n\nAdditional project-specific instructions and guidelines:\n\n${projectInstructions}\n\n</project_context>`,
    };
  });
}
