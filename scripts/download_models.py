import os
import sys


def main() -> None:
    repo_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    backend_dir = os.path.join(repo_root, "backend")
    sys.path.insert(0, backend_dir)
    from scripts.download_models import main as backend_main

    backend_main()


if __name__ == "__main__":
    main()

