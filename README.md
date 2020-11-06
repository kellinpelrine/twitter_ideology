Estimating Ideological Positions with Twitter Data
----------------

This GitHub repository contains code and materials related to the article "[Birds of a Feather Tweet Together. Bayesian Ideal Point Estimation Using Twitter Data](http://pan.oxfordjournals.org/content/23/1/76.full)," published in Political Analysis in 2015. 

The original replication code can be found in the `replication` folder. See also [Dataverse](https://dataverse.harvard.edu/dataset.xhtml?persistentId=doi:10.7910/DVN/26589) for the full replication materials, including data and output.

As an application of the method, in June 2015 I wrote a blog post on The Monkey Cage / Washington Post entitled ["Who is the most conservative Republican candidate for president?."](http://www.washingtonpost.com/blogs/monkey-cage/wp/2015/06/16/who-is-the-most-conservative-republican-candidate-for-president/) The replication code for the figure in the post is available in the `primary` folder.

Finally, this repository also contains an R package (`tweetscores`) with several functions to facilitate the application of this method in future research. The rest of this README file provides a tutorial with instructions showing how to use it

<h3>Authentication</h3>
<p>Copy below and substitute in your twitter API keys:</p>
<pre class="r"><code>install.packages(&quot;rtweet&quot;)
library(rtweet)

api_key &lt;- &quot;KEY&quot;
api_secret_key &lt;- &quot;KEY&quot;
access_token &lt;- &quot;KEY&quot;
access_token_secret &lt;- &quot;KEY&quot;

token &lt;- create_token(
  app = &quot;APP_NAME&quot;,
  consumer_key = api_key,
  consumer_secret = api_secret_key,
  access_token = access_token,
  access_secret = access_token_secret)

</div>
<div id="installing-tweetscores-package" class="section level3">
<h3>Installing the <code>tweetscores</code> package</h3>
<p>The following code will install the <code>tweetscores</code> package, as well as all other R packages necessary for the functions to run.</p>
<pre class="r"><code>toInstall &lt;- c(&quot;ggplot2&quot;, &quot;scales&quot;, &quot;R2WinBUGS&quot;, &quot;devtools&quot;, &quot;yaml&quot;, &quot;httr&quot;, &quot;RJSONIO&quot;)
install.packages(toInstall, repos = &quot;http://cran.r-project.org&quot;)
library(devtools)
install_github(&quot;kellinpelrine/twitter_ideology/pkg/tweetscores&quot;)</code></pre>
</div>
<div id="estimating-the-ideological-positions-of-a-us-twitter-user" class="section level3">
<h3>Estimating the ideological positions of a US Twitter user</h3>
<p>We can now go ahead and estimate ideology for any Twitter users in the US. In order to do so, the package includes pre-estimated ideology for political accounts and media outlets, so here we’re just replicating the second stage in the method – that is, estimating a user’s ideology based on the accounts they follow.</p>
<pre class="r"><code># load package
library(tweetscores)</code></pre>
<pre class="r"><code># downloading friends of a user
user &lt;- &quot;p_barbera&quot;
friends &lt;- getFriends(screen_name=user)</code></pre>
<pre><code>## /Users/pablobarbera/Dropbox/credentials/twitter/oauth_token_32 
## 15  API calls left
## 1065 friends. Next cursor:  0 
## 14  API calls left</code></pre>
<pre class="r"><code># estimate ideology with MCMC method
results &lt;- estimateIdeology(user, friends)</code></pre>
<pre><code>## p_barbera follows 11 elites: nytimes maddow caitlindewey carr2n fivethirtyeight 
NickKristof nytgraphics nytimesbits NYTimeskrugman nytlabs thecaucus
## Chain 1
  |=================================================================| 100%
## Chain 2
  |=================================================================| 100%
</code></pre>
<p>Once we have this set of estimates, we can analyze them with a series of built-in functions.</p>
<pre class="r"><code># summarizing results
summary(results)</code></pre>
<pre><code>##        mean   sd  2.5%   25%   50%   75% 97.5% Rhat n.eff
## beta  -2.30 0.57 -3.37 -2.72 -2.25 -1.92 -1.26 1.02   200
## theta -1.78 0.30 -2.28 -1.99 -1.82 -1.59 -1.11 1.00   200</code></pre>
<pre class="r"><code># assessing chain convergence using a trace plot
tracePlot(results, &quot;theta&quot;)</code></pre>
<p align="center"><img src="trace.png" width="650px"/></p>
<pre class="r"><code># comparing with other ideology estimates
plot(results)</code></pre>
<p align="center"><img src="plot.png" width="650px"/></p>
</div>
<div id="faster-ideology-estimation" class="section level3">
<h3>Faster ideology estimation</h3>
<p>The previous function relies on a Metropolis-Hastings sampling algorithm to estimate ideology. However, we can also use Maximum Likelihood estimation to compute the distribution of the latent parameters. This method is much faster, since it’s not sampling from the posterior distribution of the parameters, but it will tend to give smaller standard errors. However, overall the results should be almost identical. (See <a href="https://github.com/pablobarbera/twitter_ideology/blob/master/pkg/tweetscores/R/utils.R">here</a> for the actual estimation functions for each of these two approaches.)</p>
<pre class="r"><code># faster estimation using maximum likelihood
results &lt;- estimateIdeology(user, friends, method=&quot;MLE&quot;)</code></pre>
<pre><code>## p_barbera follows 11 elites: nytimes maddow caitlindewey carr2n fivethirtyeight 
NickKristof nytgraphics nytimesbits NYTimeskrugman nytlabs thecaucus</code></pre>
<pre class="r"><code>summary(results)</code></pre>
<pre><code>##        mean   sd  2.5%   25%   50%   75% 97.5% Rhat n.eff
## beta  -2.30 0.57 -3.37 -2.72 -2.25 -1.92 -1.26 1.02   200
## theta -1.78 0.30 -2.28 -1.99 -1.82 -1.59 -1.11 1.00   200</code></pre>
</div>
<div id="estimation-using-ca" class="section level3">
<h3>Estimation using correspondence analysis</h3>
<p>One limitation of the previous method is that users need to follow at least one political account. To partially overcome this problem, in a recently published <a href="http://journals.sagepub.com/doi/abs/10.1177/0956797615594620">article</a> in Psychological Science, we add a third stage to the model where we add additional accounts (not necessarily political) followed predominantely by liberal or by conservative users, under the assumption that if other users also follow this same set of accounts, they are also likely to be liberal or conservative. To reduce computational costs, we rely on correspondence analysis to project all users onto the latent ideological space (see <a href="http://www.pablobarbera.com/static/PSS-supplementary-materials.pdf">Supplementary Materials</a>), and then we normalize all the estimates so that they follow a normal distribution with mean zero and standard deviation one. This package also includes a function that reproduces the last stage in the estimation, after all the additional accounts have been added:
</p>
<pre class="r"><code># estimation using correspondence analysis
results &lt;- estimateIdeology2(user, friends)</code></pre>
<pre><code>## p_barbera follows 22 elites: andersoncooper, billclinton, BreakingNews, 
## cnnbrk, davidaxelrod, Gawker, HillaryClinton, maddow, MaddowBlog, mashable, mattyglesias,
## NateSilver538, NickKristof, nytimes, NYTimeskrugman, repjoecrowley, RonanFarrow, 
## SCOTUSblog, StephenAtHome, TheDailyShow, TheEconomist, UniteBlue</code></pre>
<pre class="r"><code>results</code></pre>
<pre><code>## [1] -1.06158</code></pre>
</div>


<div id="additional-functions" class="section level3">
<h3>Additional functions</h3>
<p>The package also contains additional functions that I use in my research, which I’m providing here in case they are useful:</p>
<ul>
<li><code>scrapeCongressData</code> is a scraper of the list of Twitter accounts for Members of the US congress from the <code>unitedstates</code> Github account.</li>
<li><code>getUsersBatch</code> scrapes user information for more than 100 Twitter users from Twitter’s REST API.</li>
<li><code>getFollower</code> scrapes followers lists from Twitter’ REST API.</li>
<li><code>CA</code> is a modified version of the <code>ca</code> function in the <code>ca</code> package (available on CRAN) that computes simple correspondence analysis with a much lower memory usage.</li>
<li><code>supplementaryColumns</code> and <code>supplementaryRows</code> takes additional columns of a follower matrix and projects them to the latent ideological space using the parameters of an already-fitted correspondence analysis model.</li>
<li><code>getCreated</code> returns the approximate date in which a Twitter account was created based on its Twitter ID. In combination with <code>estimatePastFollowers</code> and <code>estimateDateBreaks</code>, it can be used to infer past Twitter follower networks.</li>
</ul>
</div>


</div>
