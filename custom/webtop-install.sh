# Change to the abc user
mkdir -p /home/abc && cd /home/abc

# Install miniforge
curl -L -O "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(uname)-$(uname -m).sh"
bash Miniforge3-$(uname)-$(uname -m).sh -b -p /home/abc/.miniforge3
rm Miniforge3-$(uname)-$(uname -m).sh
/home/abc/.miniforge3/bin/conda init bash
/home/abc/.miniforge3/bin/conda config --set auto_activate_base false


# Install donkeycar
/home/abc/.miniforge3/bin/conda create -n donkey python=3.9 -y
mkdir projects
cd projects
git clone https://github.com/Triton-AI/donkeycar.git -b main
cd donkeycar
/home/abc/.miniforge3/envs/donkey/bin/pip install -e .[dev]

# Give change ownership to abc user
chown -R abc:abc /home/abc/