# Support

## Notice

When deploying any application on a cloud native environment, please ensure that you (or your team) have the necessary expertise in:
- Virtualization & containerization (e.g., Kubernetes, Helm, Docker, Linux).
- Cloud Platforms (e.g., AWS, Azure, GCP) and their respective orchestration tools.
- Third-party integrations (e.g., databases, APIs, monitoring tools) used alongside.
- Security & Compliance requirements for your deployment.

Otherwise, you might face potential risks as:
- Misconfiguration due to lack of expertise may lead to security vulnerabilities, performance issues, or service outages.
- Third-party dependencies (e.g., external databases, APIs) may introduce compatibility or stability risks.
- Data integrity & compliance risks if cloud-native best practices are not followed.

## Support

Before raising a support request, try to understand if it is an issue related to the Spotfire product, highly customized deployment configuration, the cloud native environment, or third party integrations.

For issues related to the Spotfire products, use the [Spotfire support channel](https://spotfi.re/support).

The Spotfire on Kubernetes product releases typically follow the main Spotfire releases. For information on the Spotfire release types (LTS and innovation releases), their cadence and support, see the [Spotfire releases overview](https://spotfi.re/lts).

When reporting issues or seeking help, make sure to collect as much relevant information as possible. Examples of such information include:

- Description of the issue, including any error messages.
- Steps to reproduce the issue, including commands and values used. 
- Time and date, identifiers such as usernames, file paths. 
- Helm, container and Kubernetes versions. 
- Any other relevant information.

The script [generate-troubleshooting-bundle.sh](https://github.com/spotfiresoftware/spotfire-cloud-deployment-kit/blob/main/utilities/generate-troubleshooting-bundle.sh) can be used as a starting point when collecting information from a Spotfire Helm deployment.

In some scenarios, there might be a need to [collect logs during an extended period of time](examples/logging-with-efk.md#collect-logs-temporarily-eg-for-troubleshooting-with-an-additional-forwarding-target).

For issues related to the cloud native environment and third party products, see the respective documentation.

## Ideas and improvements

You are welcome to raise ideas and improvements related to the [Spotfire Cloud Deployment Kit](https://github.com/spotfiresoftware/spotfire-cloud-deployment-kit) in the [GitHub Issues tab](https://github.com/spotfiresoftware/spotfire-cloud-deployment-kit/issues).

For general improvements related to the Spotfire products, use the [Ideas portal](https://spotfi.re/ideas).

