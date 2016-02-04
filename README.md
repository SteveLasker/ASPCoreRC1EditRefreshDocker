# ASPCoreRC1EditRefreshDocker
Sample project used for the [Docker Tools for Visual Studio](http://aka.ms/DockerToolsForVS/) release 11 (not yet released, please stand by)

*While the Edit & Refresh version of the Docker Tools isn't yet released, this project will work with ASP.NET 5/Core RC1*

Sample for Debugging (Edit &amp; Refresh) an ASP.NET 5 Core App in a Linux Docker Container
 
** Demonstrates:**
- Edit & Refresh of ASP.NET Core app
- Use of Docker Containers, Docker-compose
- Multi environemnt configuration using Docker Environment files
- Seperation of behaivor (appsettings.json) and location (env*.list) configuraiton settings

# Setup #
To get this sample working, you'll need the following:
- Visual Studio 2015, SP1
- [Docker Toolox](https://www.docker.com/products/overview#/docker_toolbox)
- Virutal Box [configured with a default docker host](https://docs.docker.com/machine/get-started/)
- Disable Hyper-V as Virtual Box also uses virtualization
- Save your project under the c:\Users directory as Virtual Box sets up a volume mapped share based on the c:\users directory, used by the Docker Tools for Visual Studio

## Demo Script ##
Here's my demo script:

	1. Open the baseline project
	2. F5 
		a. Show the app running under IISExpress
		b. Click the About page
		c. Notice the app doesn't load the environment vars
		d. Notice the OS
		e. We're not actully running aginst the same FX or OS as we intend for production
	3. Add Docker Support
		a. Right click on the project Add--> Docker Support
	4. F5
		a. Point out the new Docker option in the F5 targets
		b. Show app running under Docker
		c. Initial Build takes a while as we're loading a complete container, including the base image and all the nuget packages
	5. Click About
		a. Notice OS now set to ubuntu
		b. Env vars still missing
	6. Add the env files from the _artifacts folder
	7. Edit docker-compose.debug.yml
		a. Add env_file: envDevelopment.list
	8. F5
		a. Notice how much faster debugging starts as the docker image cache builds 
	9. Click About
		a. Notice our environment variables are now set
		b. Refer to the difference in behavior (debug/release) and location (development, integration, staging, production, ...)
	10. Click Contact
		a. Notice how the page errors are represented
		b. Because we're in debug mode, errors are displayed in verbose mode
	11. Edit & Refresh
		a. We don't want to rebuild the container each time
		b. In debug, we support Edit & Refresh
	12. Open Views\About
		a. Add <p>some new text</p> and save the file
	13. Refresh the browser
		a. Notice our content is now updated (you'll need a few seconds as the DNX Watch polls for changes)
	14. Let's move to Release mode and test things out
		a. Change to Release 
	15. Edit docker-compose.release.yml
		a. Add env_file: envDevelopment.list
		b. Notice our env is still development. We're separating behavior (debug/release) from the physical environment
		c. We'll plug in the staging & production physical environment values in a moment
	16. F5
		a. Open About
		b. Notice we're still using our development environment physical connections
		c. Open Contacts - see the cleaned up errors, which actually have a formatting issue. We've caught a release behavior issue we didn't see when running locally
	17. Switch to deploying
		a. Imagine we've checked in the code
		b. The build system will kick in
		c. What does our build system do?
		d. It builds the image as we did locally in release mode
		e. Lets demo this
	18. Compose up the integration environment
    	docker-compose -f docker-compose.integration.yml up -d
	19. Browse to the page
		a. This is our build system, so we don't just launch the browser automatically
		b. http://192.168.99.100:8080/Home/About (Note: docker-machine ip $(docker-machine active) to get the IP of your host
		c. Notice our URLs are INT
	20. Our "automated tests" pass
		a. Imagine our automation has passed, lets label the image and push it to our registry
		Docker images - to get the image_id
		docker tag [image_id] stevelasker/dockerenvdemo:latest
		b. Push the image to our registry
		docker push stevelasker/dockerenvdemo:latest
		c. This will actually fail as we haven't logged in, we'll skip the actual push to save time
	21. Deploy to Staging
		a. This represents our next environment
		b. Open the docker-compose.staging.yml file
		c. In this case, we don't want to rebuild the image. We know the image is fully tested
		d. We want to simply instance the image, with the environment info
	22. Open docker-compose.staging.yml
		a. Notice we're now referencing an image, not a dockerfile
		b. Notice the env_file for the location specific content
	23. Spin up the staging environment
		docker-compose -f docker-compose.staging.yml up -d
	24. Spin up the production environment
		docker-compose -f docker-compose.production.yml up -d

## List of commands ##
env_file: envDevelopment.list
docker-compose -f docker-compose.integration.yml up -d
Docker images - to get the image_id
docker tag [image_id] stevelasker/dockerenvdemo:latest
docker push stevelasker/dockerenvdemo:latest
docker-compose -f docker-compose.staging.yml up -d
docker-compose -f docker-compose.production.yml up -d

