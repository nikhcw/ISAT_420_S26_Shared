# Activity: Working with python environments

## Background

We have learned in the lecture that *python environments* allow us to maintain different python installations on the same system that contain all the python packages that we need for our work, while also maintaining potential conflicts between packages. 

It is good practice to have one environment per project or task and to share this environment with your code to ensure reproducibility of your work. 

## Learning Goals

After this practice you should be able to 

- Create a new virtual environment
- Activate an environment
- Install a package into a pre-existing python environment
- Run python code using a specific environment
- Update the environment using a `.yml` file.  

## Task

1. Create a new environment named *ISAT_420_S26*
   1. I recommend trying this on the command line. 
        - For Windows: Go the the start menu and open the `Anaconda Powershell Prompt`
        - For Apple: Open the `Terminal` in launcher and enter the neccesary commands 
1. Activate the environment and install at least the following packages: `jupyter`, `xarray`, `netcdf4`, `matplotlib`
   - Note: For some Anaconda installations (i.e. the Windows Version), the direct installation of these packages fails. This is because, they are distributed through the `conda-forge` channel.   
     You can check which channels are available like this:
   
     ```bash
     conda config --show channels
     ```
   
     If not already added you can add the `conda-forge` channel like this:
   
     ```bash
     conda config --add default_channels conda-forge
     ```        
1. Launch a jupyter notebook to test whether your installation works by running the notebook in the `Code` directory:  `w7_environment_test.ipynb`
1. (Optional): Use the provided `environment.yml` file to update your environment.
   - Note: This requires you to have the `environment.yml` file in your current working directory.
      - Here is a quick guide on how to navigate directories within the _Terminal_: [Linux Command - Shell Tutorial](https://linuxcommand.org/lc3_lts0020.php).
         - This is a bit too much information, but _Windows Powershell_ which is running in the windows _Terminal_ and _bash_ which is running on Mac and Linux are two flavours of different kinds of interactive command interpreters (also known as [Command Line Interface](https://en.wikipedia.org/wiki/Command-line_interface)). They differ in how commands are written but have sufficient overlap in the basics, that it won't matter for us.
   1. If you try to update the environment, _conda_ will be thinking for a while and try to find a combination of packages without conflicts in their dependencies. **This might fail!**
   1. If it fails, you can try to update the environment using the `environment_installed_packages.yml`. This environment file contains a list of the packages that I directly installed without all their dependencies. This means it will take longer to update and you won't have exactly the same versions for each module, but it should work.
   1. If that also fails, you can manually install all the packages listed in the `environment_installed_packages.yml`. You can install multiple packages together. For example the command below will install `numpy` and `pandas`: 
      ```
      conda install numpy pandas
      ```

## Learning Checklist

- I understand that using environments is beneficial on the long term, because it allows me to experiment with additional packages, without being afraid of breaking anything
- I am able to create new conda environments, activate them, and switch between them.
- I understand that packages installed with `conda install ...` are always installed in the environment which is currently active. `(base)` is like any other environment: it is simply the default one. 
- I am able to install new packages using `conda`. 
- I have used the environment.yml file to create a new environment for this course that contains all the packages that I need right now. 
- I know that I need to execute all code for this class using this newly created environment
