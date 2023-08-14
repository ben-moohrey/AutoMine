-- URL to the manifest file on GitHub
local manifestURL = "https://raw.githubusercontent.com/%%GITHUB_USERNAME%%/%%GITHUB_REPO%%/%%GITHUB_BRANCH%%/manifest.json"

-- Fetch the manifest from GitHub
local function fetchManifest(url)
    local handle = http.get(url)
    if not handle then
        error("Failed to fetch manifest")
    end
    local content = handle.readAll()
    handle.close()
    return textutils.unserialize(content)
end

-- Download a file from a given URL
local function downloadFile(url, path)
    local handle = http.get(url)
    if not handle then
        error("Failed to fetch " .. url)
    end
    local content = handle.readAll()
    handle.close()

    -- Ensure directory exists
    local directory = fs.getDir(path)
    if not fs.exists(directory) then
        fs.makeDir(directory)
    end

    local file = fs.open(path, "w")
    file.write(content)
    file.close()
end

local function main()
    local manifest = fetchManifest(manifestURL)
    if not manifest then
        error("Failed to parse manifest")
    end

    -- Loop through the manifest and download each file
    for path, info in pairs(manifest) do
        print("Downloading " .. path .. " from " .. info.url)
        downloadFile(info.url, path)
    end

    print("All files downloaded successfully!")
end

main()
