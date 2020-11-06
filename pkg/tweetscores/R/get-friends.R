#' @rdname getFriends
#' @export
#'
#' @title
#' Returns the list of user IDs a given Twitter user follows
#'
#' @description
#' \code{getFriends} connects to the REST API of Twitter and returns the
#' list of user IDs a given user follows. Note that this function allows the
#' use of multiple OAuth token to make the process more efficient.
#'
#' @author
#' Pablo Barbera \email{P.Barbera@@lse.ac.uk}
#' Modified by Kellin Pelrine \email{kellin.pelrine@mila.quebec}
#'
#' @param screen_name user name of the Twitter user for which their friends
#' will be downloaded
#'
#' @param cursor See \url{https://dev.twitter.com/docs/api/1.1/get/friends/ids}
#'
#' @param user_id user id of the Twitter user for which their friends will be
#' downloaded
#'
#' @param verbose If \code{TRUE}, prints information about API calls on console
#'
#' @param sleep Number of seconds to sleep between API calls.
#'
#' @examples \dontrun{
#' ## Creating OAuth token
#'  my_oauth <- list(consumer_key = "CONSUMER_KEY",
#'    consumer_secret = "CONSUMER_SECRET",
#'    access_token="ACCESS_TOKEN",
#'    access_token_secret = "ACCESS_TOKEN_SECRET")
#' ## Download list of friends of user "p_barbera"
#'  friends <- getFriends(screen_name="p_barbera", oauth=my_oauth)
#' }
#'

getFriends <- function(screen_name=NULL, cursor=-1, user_id=NULL, verbose=TRUE, sleep=1){

  ## empty list for friends
  friends <- c()
  ## while there's more data to download...
  while (cursor!=0){
    ## making API call

    json.data <- get_friends(user, parse=FALSE, retryonratelimit=TRUE, page=cursor)
    Sys.sleep(sleep)
    ## one API call less
    ##limit <- limit - 1
    ## trying to parse JSON data
    if (length(json.data$error)!=0){
      if (verbose){message(url.data)}
      stop("error! Last cursor: ", cursor)
    }
    ## adding new IDS
    friends <- c(friends, as.character(json.data$ids))

    ## previous cursor
    prev_cursor <- json.data$previous_cursor_str
    ## next cursor
    cursor <- json.data$next_cursor_str
    ## giving info
    message(length(friends), " friends. Next cursor: ", cursor)
  }
  return(friends)
}
