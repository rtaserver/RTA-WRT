git clone https://github.com/ohmyzsh/ohmyzsh.git /usr/share/ohmyzsh
git clone https://github.com/zsh-users/zsh-autosuggestions /usr/share/ohmyzsh/custom/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git /usr/share/ohmyzsh/custom/plugins/zsh-syntax-highlighting
cp /usr/share/ohmyzsh/templates/zshrc.zsh-template /usr/share/ohmyzsh/.zshrc
sed -i 's|^export ZSH="$HOME/.oh-my-zsh"|export ZSH=/usr/share/ohmyzsh|g' /usr/share/ohmyzsh/.zshrc
sed -i 's|^ZSH_THEME="robbyrussell"|ZSH_THEME="agnoster"|g' /usr/share/ohmyzsh/.zshrc
sed -i 's|^plugins=(git)|plugins=(git zsh-autosuggestions zsh-syntax-highlighting)|g' /usr/share/ohmyzsh/.zshrc
ZDOTDIR=/usr/share/ohmyzsh zsh

