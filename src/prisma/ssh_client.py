from sys import stderr
from paramiko.client import AutoAddPolicy, SSHClient


class PRISMASSHClient:
    def __init__(self, address, user=None, passwd=None):
        self.client = SSHClient()
        self.client.set_missing_host_key_policy(AutoAddPolicy())
        self.client.load_system_host_keys()
        if user is None:
            self.client.connect(address)
        else:
            if passwd is not None:
                self.client.connect(address, username=user, password=passwd)
            else:
                self.client.connect(address, username=user)

    def close(self):
        self.client.close()

    def list_from_directory(self, directory):
        stdin, stdout, stderr = self.client.exec_command("ls " + directory)
        result = stdout.read().splitlines()
        return result

    def download_file(self, remote_filepath, local_filepath):
        sftp = self.client.open_sftp()
        sftp.get(remote_filepath, local_filepath)
        sftp.close()

    def size_of_file(self, remote_filepath):
        sftp = self.client.open_sftp()
        stat = sftp.stat(remote_filepath)
        sftp.close()
        return stat.st_size

    # def sftp_walk(sftp, remotepath):
    #     path=remotepath
    #     files=[]
    #     folders=[]
    #     for f in sftp.listdir_attr(remotepath):
    #         if S_ISDIR(f.st_mode):
    #             folders.append(f.filename)
    #         else:
    #             files.append(f.filename)
    #     if files:
    #         yield path, files
    #     for folder in folders:
    #         new_path=os.path.join(remotepath,folder)
    #         for x in sftp_walk(sftp, new_path):
    #             yield x
