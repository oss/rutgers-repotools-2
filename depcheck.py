from optparse import OptionParser
import logging

MASHD="/etc/mash"
TGTD="/mnt/koji/mash"

def main(options, args):
    if options.verbose:
        logger.basicConfig(format="[%(levelname)] %(message)", 
                           level=logging.DEUG)
        logger.debug("Showing verbose output")
    else:
        logger.basicConfig(format="[%(levelname)] %(message)",
                        level=logging.INFO) 

    repo = args[0]

    if not options.directory and not repo_exists(repo):
        logging.critical("Repo does not exist: {}".format(repo))
    else:
        if options.directory:
            path = repo
        else:
            path = get_repo_path(repo)
       
        errors = depcheck_directory(path)
        if errors:
            logging.error("Dependency issues found:")
            for e in errors:
                logging.error(e)
        else:
            logging.info("No dependency issues found")


def repo_exists(repo):
    """Returns true if the repo exists in the mash directory"""
    pass

def get_repo_path(repo):
    """Returns the path of the given repo"""
    pass

def depcheck_directory(path):
    """Returns a list of dependency error messages if the repo at the given 
    directory is not clean"""
    pass


if __name__ == "__main__":
    parser = OptionParser()
    
    parser.add_option("--nomail", default=True,
                      action="store_false", dest="send_mail"
                      help="do not send email notifications")
    parser.add_option("-v", "--verbose", default=False
                      action="store_true", dest="verbose",
                      help="show verbose output")
    parser.add_option("-q", "--quiet", default=True
                      action="store_false", dest="show_output",
                      help="don't show output (will show errors)")
    parser.add_option("-d", "--directory", default=False,
                      action="store_true", dest="directory",
                      help="argument is a directory, not the name of a repo")

    (options, args) = parser.parse_args()
    main(options, args)
