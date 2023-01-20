echo "-------------------------"
echo "running prerequisites"
echo "-------------------------"
echo "checking if terraform is installed.."
if ! command -v terraform &> /dev/null
then
    echo "terraform is not installed"
    echo "existing.."
    exit
fi
echo "done."
echo "checking if ansible is installed.."
if ! command -v ansible &> /dev/null
then
    echo "ansible is not installed"
    echo "existing.."
    exit
fi
echo "done."