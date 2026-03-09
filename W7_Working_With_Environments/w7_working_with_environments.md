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
1. Activate the environment and install at least the following packages: `jupyter`, `xarray`, `netcdf4`
    1. I recommend trying this on the command line. 
        - For Windows: Go the the start menu and open the `Anaconda Prompt`
        - For Apple: Open the `Terminal` in launcher and enter the neccesary commands 
1. Launch a jupyter notebook to test whether your installation works by running the notebook in the `Code` directory:  `w7_environment_test.ipynb`
1. (Optional): Use the provided `environment.yml` file to update your environment. 

## Learning Checklist

- I understand that using environments is beneficial on the long term, because it allows me to experiment with additional packages, without being afraid of breaking anything
- I am able to create new conda environments, activate them, and switch between them.
- I understand that packages installed with `conda install ...` are always installed in the environment which is currently active. `(base)` is like any other environment: it is simply the default one. 
- I am able to install new packages using `conda`. 
- I have used the environment.yml file to create a new environment for this course that contains all the packages that I need right now. 
- I know that I need to execute all code for this class using this newly created environment