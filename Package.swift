



import PackageDescription

let package = Package(
    name: "NanoMsg",
    targets: [Target(name: "NanoMsg", dependencies: ["cnanomsg"])],
    dependencies: [
    	.Package(url: "https://github.com/open-swift/C7.git", majorVersion: 0, minor: 5),
    ]
)	