import org.apache.commons.httpclient.UsernamePasswordCredentials;
import org.apache.commons.httpclient.*;
import org.apache.commons.httpclient.auth.*;
public class SncCreds implements CredentialsProvider {

    private UsernamePasswordCredentials myCredentials;

    public SncCreds(String userName, String password) {
        myCredentials = new UsernamePasswordCredentials(userName,password);
    }

    public Credentials getCredentials(AuthScheme scheme, String host, int port, boolean proxy) throws CredentialsNotAvailableException {
		return(myCredentials);
	}

}
