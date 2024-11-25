import pkg_resources

# Set the parsed tagged version as the package version
version = pkg_resources.get_distribution('bulkrnaseq').parsed_version
if version.is_prerelease:
    __version__ = f'{version.base_version}-{".".join([str(x) for x in version.pre])}'
else:
    __version__ = version.base_version