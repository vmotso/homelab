#!/usr/bin/env python3

import os
import subprocess
import pathlib

import click

KUBECONFIG = str(pathlib.Path.cwd() / "metal" / "kubeconfig.yaml")
ANSIBLE_CONFIG = str(pathlib.Path.cwd() / "ansible.cfg")
SYSTEM_DIR = pathlib.Path.cwd() / "system"
ENV = {**os.environ, "KUBE_CONFIG_PATH": KUBECONFIG, "ANSIBLE_CONFIG": ANSIBLE_CONFIG}


def shell(cmd: str, cwd: str | None = None, stdout: bool = False):
    """Run a command in shell."""
    proc = subprocess.run(
        cmd,
        shell=True,
        check=True,
        encoding="utf-8",
        cwd=cwd,
        env=ENV,
        stdout=subprocess.PIPE if stdout else None,
    )
    return proc.stdout.strip() if proc.stdout is not None else None


def success(msg: str):
    click.secho(msg, fg="green")


def _terraform(cmd: str, cwd: str | None = None, stdout: bool = False):
    if any((cmd.startswith("plan"), cmd.startswith("apply"), cmd.startswith("destroy"))):
        cmd += " --auto-approve"
    return shell(f"terraform {cmd}", cwd=cwd, stdout=stdout)


@click.group()
def cli():
    pass


@cli.command()
def ctx():
    main = pathlib.Path(os.environ["HOME"], ".kube", "config")
    deactivated = pathlib.Path(os.environ["HOME"], ".kube", "config.deactivated")
    homelab = pathlib.Path(os.environ["PWD"], "metal", "kubeconfig.yaml")
    if deactivated.exists():
        shell(f"mv {deactivated} {main}")
        success("deactivated")
    else:
        shell(f"mv {main} {deactivated}")
        shell(f"cp {homelab} {main}")
        success("activated")


# Layer:Metal


@click.group()
def metal():
    pass


@metal.command("deploy")
def metal_deploy():
    shell("ansible-playbook -v --inventory metal/inventories/main.yml metal/deploy.yml")


@metal.command("destroy")
def metal_destroy():
    shell("ansible-playbook --inventory metal/inventories/main.yml metal/destroy.yml")


cli.add_command(metal)

# Layer: Exteral, System, Bootstrap


@click.group()
def terraform():
    pass


@terraform.command("apply")
def tf_apply():
    if not pathlib.Path("./terraform.tfstate").exists():
        _terraform("init")
    try:
        state = set(_terraform("state list", stdout=True).splitlines())
    except subprocess.CalledProcessError:
        state = set()
    # First, deploy CRD
    if "module.system.module.metallb.helm_release.metallb" not in state:
        _terraform("apply -target module.system.module.metallb.helm_release.metallb")
    if "module.system.module.cert_manager.helm_release.cert_manager" not in state:
        _terraform("apply -target module.system.module.cert_manager.helm_release.cert_manager")
    _terraform("apply")


@terraform.command("destroy")
def tf_destroy():
    _terraform("destroy")


@click.group()
def argocd():
    pass


@argocd.command("password")
def get_argocd_admin_password():
    shell(
        "kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d"
    )


cli.add_command(terraform)
cli.add_command(argocd)

if __name__ == "__main__":
    cli()
