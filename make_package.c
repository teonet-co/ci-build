/**
 * File:   make_package.c
 * Author: Kirill Scherba <kirill@scherba.ru>
 *
 * Build package
 *
 * Created on August 24, 2015, 2:22 AM
 */

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>

#define KSN_BUFFER_SM_SIZE 256

// Add configuration header
#undef PACKAGE
#undef VERSION
#undef GETTEXT_PACKAGE
#undef PACKAGE_VERSION
#undef PACKAGE_TARNAME
#undef PACKAGE_STRING
#undef PACKAGE_NAME
#undef PACKAGE_BUGREPORT
#undef PACKAGE_DESCRIPTION
#undef PACKAGE_DEPENDENCIES
#include "config.h"

#define TBP_VERSION "0.0.4"

#ifndef LIBRARY_MAJOR_VERSION
#define LIBRARY_MAJOR_VERSION 0
#endif

//#define USE_CHECKINSTALL

/**
 * Build type
 */
enum B_TYPE {

  DEB = 1, ///< Debian
  RPM,     ///< REHL/Centos/Fedora/Suse RPM created under Ubuntu
  YUM,
  ZYP
};

/**
 * Show application usage
 *
 * @param appname
 */
void show_usage(const char* appname) {

  printf("\n"
         "Usage: %s LINUX [ARCH]\n"
         "\n"
         "Where LINUX: deb - DEBIAN, "
         "rpm - RPM for Ubuntu, "
         "yum - REHL/Centos/Fedore, zyp - Opensuse\n"
         "      ARCH: architecture (default: amd64)\n"
         "\n",
         appname);
}

/**
 * Main application function
 *
 * @param argc
 * @param argv
 * @return
 */
int main(int argc, char** argv) {

  printf("Teonet build package ver. %s, %s\n", TBP_VERSION, COPYRIGHT);

  char cmd[KSN_BUFFER_SM_SIZE]; // Execute command name buffer
  int rv = EXIT_FAILURE;        // Return value
  int b_type = 0;               // Build type

  char* CI_BUILD_REF = getenv("CI_BUILD_REF");

  // Show CI_BUILD_REF
  {
    if (CI_BUILD_REF != NULL)
      printf("CI_BUILD_REF=%s\n", CI_BUILD_REF);
  }

  // Check for required arguments
  if (argc < 2) {
    show_usage(argv[0]);
    return (EXIT_FAILURE);
  }

  // Make DEBIAN repository
  if (!strcmp(argv[1], "deb"))
    b_type = DEB;
  else if (!strcmp(argv[1], "rpm"))
    b_type = RPM;
  else if (!strcmp(argv[1], "yum"))
    b_type = YUM;
  else if (!strcmp(argv[1], "zyp"))
    b_type = ZYP;

  // Check for build type
  if (!b_type) {
    show_usage(argv[0]);
    return (EXIT_FAILURE);
  }

  // DEB specific
  if (b_type == 1) {
    // Import repository keys
    if (CI_BUILD_REF != NULL)
      if (system("ci-build/make_deb_keys_add.sh"))
        return (EXIT_FAILURE);
  }

  // Get build ID from GitLab CI environment variable
  char version[KSN_BUFFER_SM_SIZE];
  char* CI_BUILD_ID = getenv("CI_BUILD_ID");
  char* CIRCLE_BUILD_NUM = getenv("CIRCLE_BUILD_NUM");

  // Get version from Teonet configuration header file
  snprintf(version, KSN_BUFFER_SM_SIZE, "%s", VERSION);

  // If use check install
  #ifdef USE_CHECKINSTALL
  if (b_type == 1) {
    const char* MAINTAINER = PACKAGE_BUGREPORT;
    printf("USE_CHECKINSTALL:\n");
    snprintf(cmd, KSN_BUFFER_SM_SIZE,
            "sudo checkinstall --maintainer=\"%s\" "
            "--pkgversion=\"%s\" --pkggroup=\"network\" --install=no "
            "--default",
            MAINTAINER, version);

    rv = system(cmd);
    // rv = system("ci-build/make_deb_keys_remove.sh");
    rv = system("sudo rm -fr docs doc-pak/");
    exit(0);
  }
  #endif

  // Execute build packet script
  snprintf(
      cmd, KSN_BUFFER_SM_SIZE,
      "ci-build/make_%s.sh %s %d %d.0.0 %s %s %s %s '%s' '%s' '%s' '%s' '%s'",
      b_type == DEB ? argv[1] : "rpm", // Script type
      // Script parameters
      version,               // $1 Version
      LIBRARY_MAJOR_VERSION, // $2 Library major version
      LIBRARY_MAJOR_VERSION, // $3 Library version
      CI_BUILD_ID != NULL && CI_BUILD_ID[0]
          ? CI_BUILD_ID
          : (CIRCLE_BUILD_NUM != NULL && CIRCLE_BUILD_NUM[0] ? CIRCLE_BUILD_NUM
                                                             : "1"), // $4 Build
      argc >= 3 ? argv[2]
                : b_type == DEB ? "amd64" : "x86_64", // $5 Architecture
      b_type > DEB ? argv[1] : "deb",                 // $6 RPM subtype
      PACKAGE_NAME,                     // $7 Package name (default: libteonet)
      PACKAGE_DESCRIPTION,              // $8 Package description (default: ...)
      PACKAGE_BUGREPORT,                // $9 Package Maintainer
      PACKAGE_DEPENDENCIES,             // $10 Package dependencies
      LICENSES,
      VCS_URL
      ) < 0
      ? abort()
      : (void)0;

  printf("%s\n\n", cmd);
  rv = system(cmd);

  return rv != 0;
}
