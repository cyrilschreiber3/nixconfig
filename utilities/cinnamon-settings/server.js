const http = require("http");
const fs = require("fs").promises;
const path = require("path");
const url = require("url");

const PORT = 3002;
const CONFIG_PATH = "./../../modules/dotfiles/cinnamon/";

const server = http.createServer(async (req, res) => {
	const parsedUrl = url.parse(req.url, true);

	if (req.method === "GET" && parsedUrl.pathname === "/") {
		// Serve the HTML file
		try {
			const content = await fs.readFile("index.html", "utf8");
			res.writeHead(200, { "Content-Type": "text/html" });
			res.end(content);
		} catch (error) {
			res.writeHead(500, { "Content-Type": "text/plain" });
			res.end("Internal Server Error");
		}
	} else if (req.method === "GET" && parsedUrl.pathname === "/directory_structure.json") {
		// Serve the directory structure
		try {
			const structure = await getDirectoryStructure(CONFIG_PATH);
			res.writeHead(200, { "Content-Type": "application/json" });
			res.end(JSON.stringify(structure));
		} catch (error) {
			res.writeHead(500, { "Content-Type": "text/plain" });
			res.end("Internal Server Error");
		}
	} else if (req.method === "GET" && parsedUrl.pathname.startsWith("/modules/")) {
		// Serve individual JSON files
		const filePath = path.join(CONFIG_PATH, parsedUrl.pathname.slice(9));
		try {
			const content = await fs.readFile(filePath, "utf8");
			res.writeHead(200, { "Content-Type": "application/json" });
			res.end(content);
		} catch (error) {
			res.writeHead(404, { "Content-Type": "text/plain" });
			res.end("Not Found");
		}
	} else if (req.method === "POST" && parsedUrl.pathname === "/update") {
		// Handle setting updates
		let body = "";
		req.on("data", (chunk) => {
			body += chunk.toString();
		});
		req.on("end", async () => {
			try {
				const { module, file, key, value } = JSON.parse(body);
				await updateSetting(module, file, key, value);
				res.writeHead(200, { "Content-Type": "text/plain" });
				res.end("Setting updated successfully");
			} catch (error) {
				res.writeHead(400, { "Content-Type": "text/plain" });
				res.end("Bad Request");
			}
		});
	} else {
		res.writeHead(404, { "Content-Type": "text/plain" });
		res.end("Not Found");
	}
});

async function getDirectoryStructure(dir) {
	const structure = {};
	const entries = await fs.readdir(dir, { withFileTypes: true });

	for (const entry of entries) {
		if (entry.isDirectory()) {
			const files = await fs.readdir(path.join(dir, entry.name));
			structure[entry.name] = {};
			for (const file of files) {
				if (path.extname(file) === ".json") {
					structure[entry.name][file] = true;
				}
			}
		}
	}

	return structure;
}

async function updateSetting(module, file, key, value) {
	const filePath = path.join(CONFIG_PATH, module, file);
	try {
		const content = await fs.readFile(filePath, "utf8");
		const settings = JSON.parse(content);
		if (settings.hasOwnProperty(key)) {
			settings[key].value = value;
			await fs.writeFile(filePath, JSON.stringify(settings, null, 2));
		} else {
			throw new Error("Setting not found");
		}
	} catch (error) {
		console.error("Error updating setting:", error);
		throw error;
	}
}

server.listen(PORT, () => {
	console.log(`Server running at http://localhost:${PORT}/`);
});
