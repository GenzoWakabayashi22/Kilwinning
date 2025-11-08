#!/usr/bin/env python3
"""
Genera un file project.pbxproj per Xcode con tutti i file Swift
"""

import os
import hashlib
from pathlib import Path

def generate_uuid(seed):
    """Genera un UUID deterministico da un seed"""
    return hashlib.md5(seed.encode()).hexdigest()[:24].upper()

# Trova tutti i file Swift
swift_files = []
project_root = Path("KilwinningXcode/Kilwinning")

for swift_file in sorted(project_root.rglob("*.swift")):
    rel_path = swift_file.relative_to(project_root)
    swift_files.append(str(rel_path))

# Genera UUIDs per ogni file
file_refs = {}
build_files = {}

for f in swift_files:
    file_refs[f] = generate_uuid(f"fileref_{f}")
    build_files[f] = generate_uuid(f"buildfile_{f}")

# Altri UUIDs necessari
main_group_id = generate_uuid("main_group")
products_group_id = generate_uuid("products_group")
sources_phase_id = generate_uuid("sources_phase")
resources_phase_id = generate_uuid("resources_phase")
frameworks_phase_id = generate_uuid("frameworks_phase")
target_id = generate_uuid("target")
project_id = generate_uuid("project")
config_list_project_id = generate_uuid("config_list_project")
config_list_target_id = generate_uuid("config_list_target")
debug_config_id = generate_uuid("debug_config")
release_config_id = generate_uuid("release_config")
app_product_id = generate_uuid("app_product")
info_plist_id = generate_uuid("info_plist")
assets_id = generate_uuid("assets")
config_plist_id = generate_uuid("config_plist")

# Gruppi per organizzazione
core_group_id = generate_uuid("core_group")
models_group_id = generate_uuid("models_group")
views_group_id = generate_uuid("views_group")
services_group_id = generate_uuid("services_group")
repositories_group_id = generate_uuid("repositories_group")
utilities_group_id = generate_uuid("utilities_group")

# Crea il file project.pbxproj
pbxproj_content = f"""// !$*UTF8*$!
{{
	archiveVersion = 1;
	classes = {{
	}};
	objectVersion = 56;
	objects = {{

/* Begin PBXBuildFile section */
"""

# Aggiungi tutti i file Swift alla build phase
for f, uuid in build_files.items():
    file_ref = file_refs[f]
    pbxproj_content += f"\t\t{uuid} /* {f} in Sources */ = {{isa = PBXBuildFile; fileRef = {file_ref} /* {f} */; }};\n"

# Aggiungi Assets e Config.plist
pbxproj_content += f"\t\t{generate_uuid('buildfile_assets')} /* Assets.xcassets in Resources */ = {{isa = PBXBuildFile; fileRef = {assets_id} /* Assets.xcassets */; }};\n"
pbxproj_content += f"\t\t{generate_uuid('buildfile_config')} /* Config.plist in Resources */ = {{isa = PBXBuildFile; fileRef = {config_plist_id} /* Config.plist */; }};\n"

pbxproj_content += """/* End PBXBuildFile section */

/* Begin PBXFileReference section */
"""

# File references
pbxproj_content += f"\t\t{app_product_id} /* Kilwinning.app */ = {{isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = Kilwinning.app; sourceTree = BUILT_PRODUCTS_DIR; }};\n"
pbxproj_content += f"\t\t{info_plist_id} /* Info.plist */ = {{isa = PBXFileReference; lastKnownFileType = text.plist.xml; path = Info.plist; sourceTree = \"<group>\"; }};\n"
pbxproj_content += f"\t\t{assets_id} /* Assets.xcassets */ = {{isa = PBXFileReference; lastKnownFileType = folder.assetcatalog; path = Assets.xcassets; sourceTree = \"<group>\"; }};\n"
pbxproj_content += f"\t\t{config_plist_id} /* Config.plist */ = {{isa = PBXFileReference; lastKnownFileType = text.plist.xml; path = Config.plist; sourceTree = \"<group>\"; }};\n"

for f, uuid in file_refs.items():
    pbxproj_content += f"\t\t{uuid} /* {f} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = \"{os.path.basename(f)}\"; sourceTree = \"<group>\"; }};\n"

pbxproj_content += """/* End PBXFileReference section */

/* Begin PBXFrameworksBuildPhase section */
"""
pbxproj_content += f"""\t\t{frameworks_phase_id} /* Frameworks */ = {{
			isa = PBXFrameworksBuildPhase;
			buildActionMask = 2147483647;
			files = (
			);
			runOnlyForDeploymentPostprocessing = 0;
		}};
/* End PBXFrameworksBuildPhase section */

/* Begin PBXGroup section */
"""

# Main group
pbxproj_content += f"""\t\t{main_group_id} = {{
			isa = PBXGroup;
			children = (
				{core_group_id} /* Core */,
				{models_group_id} /* Models */,
				{views_group_id} /* Views */,
				{services_group_id} /* Services */,
				{repositories_group_id} /* Repositories */,
				{utilities_group_id} /* Utilities */,
				{file_refs['KilwinningApp.swift']} /* KilwinningApp.swift */,
				{info_plist_id} /* Info.plist */,
				{assets_id} /* Assets.xcassets */,
				{config_plist_id} /* Config.plist */,
				{products_group_id} /* Products */,
			);
			sourceTree = \"<group>\";
		}};
"""

# Products group
pbxproj_content += f"""\t\t{products_group_id} /* Products */ = {{
			isa = PBXGroup;
			children = (
				{app_product_id} /* Kilwinning.app */,
			);
			name = Products;
			sourceTree = \"<group>\";
		}};
"""

# Core group
core_files = [f for f in swift_files if f.startswith("Core/")]
pbxproj_content += f"""\t\t{core_group_id} /* Core */ = {{
			isa = PBXGroup;
			children = (
"""
for f in core_files:
    pbxproj_content += f"\t\t\t\t{file_refs[f]} /* {os.path.basename(f)} */,\n"
pbxproj_content += """\t\t\t);
			path = Core;
			sourceTree = \"<group>\";
		};
"""

# Models group
models_files = [f for f in swift_files if f.startswith("Models/")]
pbxproj_content += f"""\t\t{models_group_id} /* Models */ = {{
			isa = PBXGroup;
			children = (
"""
for f in models_files:
    pbxproj_content += f"\t\t\t\t{file_refs[f]} /* {os.path.basename(f)} */,\n"
pbxproj_content += """\t\t\t);
			path = Models;
			sourceTree = \"<group>\";
		};
"""

# Views group
views_files = [f for f in swift_files if f.startswith("Views/")]
pbxproj_content += f"""\t\t{views_group_id} /* Views */ = {{
			isa = PBXGroup;
			children = (
"""
for f in views_files:
    pbxproj_content += f"\t\t\t\t{file_refs[f]} /* {os.path.basename(f)} */,\n"
pbxproj_content += """\t\t\t);
			path = Views;
			sourceTree = \"<group>\";
		};
"""

# Services group
services_files = [f for f in swift_files if f.startswith("Services/")]
pbxproj_content += f"""\t\t{services_group_id} /* Services */ = {{
			isa = PBXGroup;
			children = (
"""
for f in services_files:
    pbxproj_content += f"\t\t\t\t{file_refs[f]} /* {os.path.basename(f)} */,\n"
pbxproj_content += """\t\t\t);
			path = Services;
			sourceTree = \"<group>\";
		};
"""

# Repositories group
repositories_files = [f for f in swift_files if f.startswith("Repositories/")]
pbxproj_content += f"""\t\t{repositories_group_id} /* Repositories */ = {{
			isa = PBXGroup;
			children = (
"""
for f in repositories_files:
    pbxproj_content += f"\t\t\t\t{file_refs[f]} /* {os.path.basename(f)} */,\n"
pbxproj_content += """\t\t\t);
			path = Repositories;
			sourceTree = \"<group>\";
		};
"""

# Utilities group
utilities_files = [f for f in swift_files if f.startswith("Utilities/")]
pbxproj_content += f"""\t\t{utilities_group_id} /* Utilities */ = {{
			isa = PBXGroup;
			children = (
"""
for f in utilities_files:
    pbxproj_content += f"\t\t\t\t{file_refs[f]} /* {os.path.basename(f)} */,\n"
pbxproj_content += """\t\t\t);
			path = Utilities;
			sourceTree = \"<group>\";
		};
"""

pbxproj_content += """/* End PBXGroup section */

/* Begin PBXNativeTarget section */
"""

pbxproj_content += f"""\t\t{target_id} /* Kilwinning */ = {{
			isa = PBXNativeTarget;
			buildConfigurationList = {config_list_target_id} /* Build configuration list for PBXNativeTarget "Kilwinning" */;
			buildPhases = (
				{sources_phase_id} /* Sources */,
				{frameworks_phase_id} /* Frameworks */,
				{resources_phase_id} /* Resources */,
			);
			buildRules = (
			);
			dependencies = (
			);
			name = Kilwinning;
			productName = Kilwinning;
			productReference = {app_product_id} /* Kilwinning.app */;
			productType = \"com.apple.product-type.application\";
		}};
/* End PBXNativeTarget section */

/* Begin PBXProject section */
"""

pbxproj_content += f"""\t\t{project_id} /* Project object */ = {{
			isa = PBXProject;
			attributes = {{
				BuildIndependentTargetsInParallel = 1;
				LastSwiftUpdateCheck = 1500;
				LastUpgradeCheck = 1500;
				TargetAttributes = {{
					{target_id} = {{
						CreatedOnToolsVersion = 15.0;
					}};
				}};
			}};
			buildConfigurationList = {config_list_project_id} /* Build configuration list for PBXProject "Kilwinning" */;
			compatibilityVersion = \"Xcode 14.0\";
			developmentRegion = en;
			hasScannedForEncodings = 0;
			knownRegions = (
				en,
				Base,
			);
			mainGroup = {main_group_id};
			productRefGroup = {products_group_id} /* Products */;
			projectDirPath = \"\";
			projectRoot = \"\";
			targets = (
				{target_id} /* Kilwinning */,
			);
		}};
/* End PBXProject section */

/* Begin PBXResourcesBuildPhase section */
"""

pbxproj_content += f"""\t\t{resources_phase_id} /* Resources */ = {{
			isa = PBXResourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
				{generate_uuid('buildfile_assets')} /* Assets.xcassets in Resources */,
				{generate_uuid('buildfile_config')} /* Config.plist in Resources */,
			);
			runOnlyForDeploymentPostprocessing = 0;
		}};
/* End PBXResourcesBuildPhase section */

/* Begin PBXSourcesBuildPhase section */
"""

pbxproj_content += f"""\t\t{sources_phase_id} /* Sources */ = {{
			isa = PBXSourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
"""

for f, uuid in build_files.items():
    pbxproj_content += f"\t\t\t\t{uuid} /* {f} in Sources */,\n"

pbxproj_content += """\t\t\t);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXSourcesBuildPhase section */

/* Begin XCBuildConfiguration section */
"""

# Debug configuration
pbxproj_content += f"""\t\t{debug_config_id} /* Debug */ = {{
			isa = XCBuildConfiguration;
			buildSettings = {{
				ALWAYS_SEARCH_USER_PATHS = NO;
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
				CLANG_ANALYZER_NONNULL = YES;
				CLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;
				CLANG_CXX_LANGUAGE_STANDARD = \"gnu++20\";
				CLANG_ENABLE_MODULES = YES;
				CLANG_ENABLE_OBJC_ARC = YES;
				CLANG_ENABLE_OBJC_WEAK = YES;
				CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING = YES;
				CLANG_WARN_BOOL_CONVERSION = YES;
				CLANG_WARN_COMMA = YES;
				CLANG_WARN_CONSTANT_CONVERSION = YES;
				CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS = YES;
				CLANG_WARN_DIRECT_OBJC_ISA_USAGE = YES_ERROR;
				CLANG_WARN_DOCUMENTATION_COMMENTS = YES;
				CLANG_WARN_EMPTY_BODY = YES;
				CLANG_WARN_ENUM_CONVERSION = YES;
				CLANG_WARN_INFINITE_RECURSION = YES;
				CLANG_WARN_INT_CONVERSION = YES;
				CLANG_WARN_NON_LITERAL_NULL_CONVERSION = YES;
				CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF = YES;
				CLANG_WARN_OBJC_LITERAL_CONVERSION = YES;
				CLANG_WARN_OBJC_ROOT_CLASS = YES_ERROR;
				CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER = YES;
				CLANG_WARN_RANGE_LOOP_ANALYSIS = YES;
				CLANG_WARN_STRICT_PROTOTYPES = YES;
				CLANG_WARN_SUSPICIOUS_MOVE = YES;
				CLANG_WARN_UNGUARDED_AVAILABILITY = YES_AGGRESSIVE;
				CLANG_WARN_UNREACHABLE_CODE = YES;
				CLANG_WARN__DUPLICATE_METHOD_MATCH = YES;
				CODE_SIGN_STYLE = Automatic;
				COPY_PHASE_STRIP = NO;
				CURRENT_PROJECT_VERSION = 1;
				DEBUG_INFORMATION_FORMAT = dwarf;
				DEVELOPMENT_TEAM = "";
				ENABLE_STRICT_OBJC_MSGSEND = YES;
				ENABLE_TESTABILITY = YES;
				GCC_C_LANGUAGE_STANDARD = gnu11;
				GCC_DYNAMIC_NO_PIC = NO;
				GCC_NO_COMMON_BLOCKS = YES;
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_PREPROCESSOR_DEFINITIONS = (
					\"DEBUG=1\",
					\"$(inherited)\",
				);
				GCC_WARN_64_TO_32_BIT_CONVERSION = YES;
				GCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
				GCC_WARN_UNDECLARED_SELECTOR = YES;
				GCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
				GCC_WARN_UNUSED_FUNCTION = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				GENERATE_INFOPLIST_FILE = NO;
				INFOPLIST_FILE = Kilwinning/Info.plist;
				INFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents = YES;
				INFOPLIST_KEY_UILaunchScreen_Generation = YES;
				INFOPLIST_KEY_UISupportedInterfaceOrientations = \"UIInterfaceOrientationPortrait UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight\";
				INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad = \"UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight\";
				IPHONEOS_DEPLOYMENT_TARGET = 17.0;
				LD_RUNPATH_SEARCH_PATHS = (
					\"$(inherited)\",
					\"@executable_path/Frameworks\",
				);
				MARKETING_VERSION = 1.0;
				MTL_ENABLE_DEBUG_INFO = INCLUDE_SOURCE;
				MTL_FAST_MATH = YES;
				ONLY_ACTIVE_ARCH = YES;
				PRODUCT_BUNDLE_IDENTIFIER = com.kilwinning.app;
				PRODUCT_NAME = \"$(TARGET_NAME)\";
				SDKROOT = iphoneos;
				SWIFT_ACTIVE_COMPILATION_CONDITIONS = DEBUG;
				SWIFT_OPTIMIZATION_LEVEL = \"-Onone\";
				SWIFT_VERSION = 5.0;
				TARGETED_DEVICE_FAMILY = \"1,2\";
			}};
			name = Debug;
		}};
"""

# Release configuration
pbxproj_content += f"""\t\t{release_config_id} /* Release */ = {{
			isa = XCBuildConfiguration;
			buildSettings = {{
				ALWAYS_SEARCH_USER_PATHS = NO;
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
				CLANG_ANALYZER_NONNULL = YES;
				CLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;
				CLANG_CXX_LANGUAGE_STANDARD = \"gnu++20\";
				CLANG_ENABLE_MODULES = YES;
				CLANG_ENABLE_OBJC_ARC = YES;
				CLANG_ENABLE_OBJC_WEAK = YES;
				CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING = YES;
				CLANG_WARN_BOOL_CONVERSION = YES;
				CLANG_WARN_COMMA = YES;
				CLANG_WARN_CONSTANT_CONVERSION = YES;
				CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS = YES;
				CLANG_WARN_DIRECT_OBJC_ISA_USAGE = YES_ERROR;
				CLANG_WARN_DOCUMENTATION_COMMENTS = YES;
				CLANG_WARN_EMPTY_BODY = YES;
				CLANG_WARN_ENUM_CONVERSION = YES;
				CLANG_WARN_INFINITE_RECURSION = YES;
				CLANG_WARN_INT_CONVERSION = YES;
				CLANG_WARN_NON_LITERAL_NULL_CONVERSION = YES;
				CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF = YES;
				CLANG_WARN_OBJC_LITERAL_CONVERSION = YES;
				CLANG_WARN_OBJC_ROOT_CLASS = YES_ERROR;
				CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER = YES;
				CLANG_WARN_RANGE_LOOP_ANALYSIS = YES;
				CLANG_WARN_STRICT_PROTOTYPES = YES;
				CLANG_WARN_SUSPICIOUS_MOVE = YES;
				CLANG_WARN_UNGUARDED_AVAILABILITY = YES_AGGRESSIVE;
				CLANG_WARN_UNREACHABLE_CODE = YES;
				CLANG_WARN__DUPLICATE_METHOD_MATCH = YES;
				CODE_SIGN_STYLE = Automatic;
				COPY_PHASE_STRIP = NO;
				CURRENT_PROJECT_VERSION = 1;
				DEBUG_INFORMATION_FORMAT = \"dwarf-with-dsym\";
				DEVELOPMENT_TEAM = "";
				ENABLE_NS_ASSERTIONS = NO;
				ENABLE_STRICT_OBJC_MSGSEND = YES;
				GCC_C_LANGUAGE_STANDARD = gnu11;
				GCC_NO_COMMON_BLOCKS = YES;
				GCC_WARN_64_TO_32_BIT_CONVERSION = YES;
				GCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
				GCC_WARN_UNDECLARED_SELECTOR = YES;
				GCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
				GCC_WARN_UNUSED_FUNCTION = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				GENERATE_INFOPLIST_FILE = NO;
				INFOPLIST_FILE = Kilwinning/Info.plist;
				INFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents = YES;
				INFOPLIST_KEY_UILaunchScreen_Generation = YES;
				INFOPLIST_KEY_UISupportedInterfaceOrientations = \"UIInterfaceOrientationPortrait UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight\";
				INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad = \"UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight\";
				IPHONEOS_DEPLOYMENT_TARGET = 17.0;
				LD_RUNPATH_SEARCH_PATHS = (
					\"$(inherited)\",
					\"@executable_path/Frameworks\",
				);
				MARKETING_VERSION = 1.0;
				MTL_ENABLE_DEBUG_INFO = NO;
				MTL_FAST_MATH = YES;
				PRODUCT_BUNDLE_IDENTIFIER = com.kilwinning.app;
				PRODUCT_NAME = \"$(TARGET_NAME)\";
				SDKROOT = iphoneos;
				SWIFT_COMPILATION_MODE = wholemodule;
				SWIFT_OPTIMIZATION_LEVEL = \"-O\";
				SWIFT_VERSION = 5.0;
				TARGETED_DEVICE_FAMILY = \"1,2\";
				VALIDATE_PRODUCT = YES;
			}};
			name = Release;
		}};
/* End XCBuildConfiguration section */

/* Begin XCConfigurationList section */
"""

pbxproj_content += f"""\t\t{config_list_project_id} /* Build configuration list for PBXProject "Kilwinning" */ = {{
			isa = XCConfigurationList;
			buildConfigurations = (
				{debug_config_id} /* Debug */,
				{release_config_id} /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		}};
\t\t{config_list_target_id} /* Build configuration list for PBXNativeTarget "Kilwinning" */ = {{
			isa = XCConfigurationList;
			buildConfigurations = (
				{debug_config_id} /* Debug */,
				{release_config_id} /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		}};
/* End XCConfigurationList section */
\t}};
\trootObject = {project_id} /* Project object */;
}}
"""

# Scrivi il file
output_dir = Path("KilwinningXcode/Kilwinning.xcodeproj")
output_dir.mkdir(exist_ok=True)
output_file = output_dir / "project.pbxproj"

with open(output_file, 'w') as f:
    f.write(pbxproj_content)

print(f"✅ Progetto Xcode generato: {output_file}")
print(f"📝 File Swift inclusi: {len(swift_files)}")
print(f"🎯 Bundle ID: com.kilwinning.app")
print(f"📱 Target: iOS 17.0+")
