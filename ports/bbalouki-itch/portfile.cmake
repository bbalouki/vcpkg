vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO bbalouki/itchcpp
    REF "v${VERSION}"
    SHA512 f35def9e84b68b47d4dd139a53243e263add0e706ee28548df3c4f89870fa6c383ca3a2b77dbd30a67d920f937ca0cc6b86cf80790f78037c98f3ac47d228420
    HEAD_REF main
    PATCHES
        fix-cmake-package.patch
        fix-python-feature.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        arrow ITCH_WITH_ARROW
        python ITCH_BUILD_PYTHON
)

set(PYTHON_OPTIONS)
if("python" IN_LIST FEATURES)
    vcpkg_get_vcpkg_installed_python(PYTHON3)
    list(APPEND PYTHON_OPTIONS
        -DPYBIND11_FINDPYTHON=ON
        "-DPython_EXECUTABLE=${PYTHON3}"
        "-DITCH_PYTHON_INSTALL_DIR=${PYTHON3_SITE}/itchcpp"
    )
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        ${PYTHON_OPTIONS}
        -DITCH_BUILD_TESTS=OFF
        -DITCH_BUILD_BENCHMARKS=OFF
        -DITCH_BUILD_EXAMPLES=OFF
        -DITCH_PROJECT_ENV=PROD
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME "itch"
    CONFIG_PATH "lib/cmake/itch"
   
)
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
