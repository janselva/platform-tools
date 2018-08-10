from hdfs import Client
import requests
import base64

class SecureClient(Client):

  """A new client subclass for handling HTTPS connections.

  :param url: URL to namenode.
  :param cert: Local certificate. See `requests` documentation for details
    on how to use this.
  :param verify: Whether to check the host's certificate.
  :param \*\*kwargs: Keyword arguments passed to the default `Client`
    constructor.

  """
  def __init__(self, url, verify=None, user=None, password=None, **kwargs):
    session = requests.Session()
    user = base64.b64decode(user)
    password = base64.b64decode(password)
    session.auth = (user, password)
    session.verify = verify
    super(SecureClient, self).__init__(url, session=session, **kwargs)
