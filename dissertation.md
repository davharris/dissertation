---
numbersections: true
---
\numberwithin{figure}{section}
\pagenumbering{roman}
\setstretch{1}
\setlength{\parskip}{9pt}

\begin{center}

\textbf{Multi-Process Statistical Modeling of Species' Joint Distributions}  

By

DAVID JAY HARRIS

Bachelor of Arts (Washington University in St. Louis) 2008

DISSERTATION

Submitted in partial satisfaction of the requirements for the degree of

DOCTOR OF PHILOSOPHY

in

Population Biology

in the

OFFICE OF GRADUATE STUDIES

of the

UNIVERSITY OF CALIFORNIA

DAVIS

Approved:

\setlength{\parskip}{20pt}

\underline{\hspace{8cm}}\\
Andrew Sih, Chair

\underline{\hspace{8cm}}\\
Marissa L. Baskett

\underline{\hspace{8cm}}\\
Robert Hijmans

\underline{\hspace{8cm}}\\
Richard McElreath


Committee in charge

2015

\end{center}
\setlength{\parskip}{6pt}

\newpage

\hypersetup{linkcolor=black}
\tableofcontents

\newpage
\setstretch{2}

## Abstract

asdf

\newpage

## Acknowledgements

asdf

\newpage


\newpage

\pagenumbering{arabic}
\setcounter{page}{1}

# Generating realistic assemblages with a Joint Species Distribution Model

David J. Harris

## Introduction
A major goal of community ecology is to understand the processes, such as environmental filtering and species interactions, that determine where species could occur and which species can occur together [@chase_community_2003].
Traditional multivariate methods for studying these issues in community ecology---such as ordination techniques for summarizing a data matrix's multivariate geometry---will not always provide the best approach to these questions, as they typically do not specify a data-generating mechanism or make predictions about new assemblages [but see @walker_random-effects_2011].
More recent approaches, such as generalized linear models [@jackson_seeing_2012; @wang_mvabundr_2012; @jamil_generalized_2013] and species distribution models [SDMs; @elith_species_2009], can make specific predictions. Just as importantly, these predictions can be evaluated quantitatively based on their likelihoods.

Modern SDMs need not assume that species respond to environmental variation in a pre-specified way (e.g. linearly or quadratically); relaxing this assumption has improved our ability to make predictions about individual species [@elith_novel_2006].
For many community-level questions, however, species-level predictions may be of limited use.
While SDMs can be combined ("stacked") to generate assemblage-level predictions [@pellissier_probabilistic_2013], doing so implies that species' occurrence probabilities are uncorrelated [@calabrese_stacking_2014; @clark_more_2013].
Ignoring the (potentially unobserved) factors driving these correlations can lead stacked models to generate incoherent jumbles of species rather than realistic assemblages [@clark_more_2013].
Given that most models only use climate variables as predictors [@austin_improving_2011], the set of unobserved factors will usually include *all of ecology* apart from climatic influences.
SDMs' failure to include other ecological processes is thus widely considered to be a major omission from statistical ecology's toolbox [@austin_improving_2011; @guisan_sesam_2011; @kissling_towards_2012; @wisz_role_2013; @clark_more_2013].

In the last few years, several mixed models have been proposed to help explain the co-occurrence patterns that stacked SDMs ignore [@latimer_hierarchical_2009; @ovaskainen_modeling_2010; @golding_phd_2013; @clark_more_2013; @pollock_understanding_2014].
These *joint* species distribution models (JSDMs) can produce mixtures of possible species assemblages (points in Figure 1a), rather than relying on a small number of environmental measurements to fully describe each species' probability of occurrence (which would collapse the distribution in Figure 1a to a single point).
In JSDMs (as in nature), a given set of climate estimates could be consistent with a number of different sets of co-occurring species, depending on factors that ecologists have not necessarily measured or even identified as important.
JSDMs represent these unobserved (latent) factors as random variables whose true values are unknown, but whose existence would still help explain discrepancies between the data and the stacked SDMs' predictions (Figure 1).
While JSDMs represent a major advance in community-level modeling [@clark_more_2013; @pollock_understanding_2014], existing implementations have all assumed that species' responses to the environment are linear (in the sense of a generalized linear model), limiting their accuracy and utility.


![Unobserved environmental heterogeneity can induce correlations between species; ignoring this heterogeneity can produce misleading results.
**A**: Based on climate predictors, a pair of single-species models might predict 50% occurrence probabilities for each of two wetland species (black cross).
Climate predictors are not sufficient in this case, however: a site's suitability for these species cannot be fully determined without information about the availability of wetland habitat.
Real habitats will to be tend to be suitable for both species (dense cloud of points in upper-right corner) or neither (lower-left corner), depending on this unmeasured variable.
**B** This correlation among species substantially alters the set of assemblages one would expect to observe. (Under independence, all four possibilities would be equally probable.)
**C** Positive correlations among species can even induce a strongly bimodal distribution of species richness values.
](figures/1/Figure-1.pdf)

Here, I present a new R package for assemblage-level modeling---called *mistnet*---that does not rely on independence (as stacks of single-species models do) or linearity (as previous JSDMs have).
Mistnet models are stochastic feed-forward neural networks [@neal_connectionist_1992; @tang_learning_2013] that combine the flexibility of modern nonlinear models with the latent variables found in previous JSDMs.
To demonstrate the value of this approach, I compared mistnet's predictive likelihood with that of several existing models, using observational data from thousands of North American Breeding Bird Survey transects [BBS; @sauer_north_2011].
A high predictive likelihood indicates that the model correctly expects to see the kinds of assemblages that were actually found out-of-sample, while a very low likelihood means that the model has effectively ruled those assemblages out due to overfitting or underfitting.

An accurate JSDM would up new possibilities for research and effective management.
For example, although most models only have access to climate data [@austin_improving_2011], a successful model of community structure should also be able to identify the major axes of non-climate variation that drive species turnover based on the species' observed co-occurrence patterns.
Moreover, a successful assemblage-level model would be able to take advantage of the presence (or absence) of indicator species to inform its predictions about the rest of the assemblage.
This ability to transfer information from easily-detected, well-documented taxa to more cryptic or rare species would prove valuable for community ecologists and conservationists alike.

## Materials and Methods

Methods are presented in five main sections:

* A description of the data sets used
* An introduction to stochastic neural networks and the mistnet package
* The specific mistnet model used here
* A summary of the existing methods used for model comparison
* Criteria for model evaluation

### Data

Field observations were obtained from the 2011 Breeding Bird Survey [BBS; @sauer_north_2011].
The BBS data consists of thousands of transects ("routes"), which served as the main unit for the analysis.
Each route includes 50 stops, about 0.8 km apart.
At each stop, all the birds observed in a 3-minute period are recorded, using a standardized procedure.
Following BBS recommendations, I omitted nonstandard routes and data collected on days with bad weather.

To evaluate SDMs' predictive capabilities, I split the routes into a "training" data set consisting of 1559 routes and a "test" data set consisting of 280 routes (Figure 2; Appendix A).
The two data sets were separated by a 150-km buffer to ensure that models could not rely on spatial autocorrelation to make accurate predictions about the test set [c.f. @bahn_can_2007; Appendix A].
Each model was fit to the same training set, and then its performance was evaluated out-of-sample on the test set.

![Map of the BBS routes used in this analysis. Black points are training routes; red ones are test routes. The training and test routes are separated by a 150-km buffer in order to minimize spatial autocorrelation across the two partitions.](figures/1/map.png)

Observational data for each species was reduced to "presence" or "absence" at the route level, ignoring the possibility of observation error for the purposes of this analysis.
368 species were chosen for analysis according to a procedure described in Appendix A.

I extracted the 19 Bioclim climate variables for each route from Worldclim [version 1.4; @hijmans_very_2005] for use as environmental predictors.
After removing predictors that were nearly collinear, eight climate-based predictors remained for the analyses (Appendix A).
Since most SDMs do not use land cover data [@austin_improving_2011] and one of mistnet's goals is to make inferences about unobserved environmental variation, no other variables were included in this analysis.

Finally, I obtained habitat classifications for each species from the Cornell Lab of Ornithology's All About Birds website (AAB; www.allaboutbirds.org) using an R script written by K. E. Dybala.

### Introduction to stochastic neural networks

This section discusses the stochastic networks in general terms; the specific model used for avian communities is discussed in the following section.
In general, ecologists have not had much success using neural networks for SDM [e.g. @dormann_components_2008], but neural networks' recent success in other machine learning contexts [including contexts with latent random variables; @murphy_machine_2012; @bengio_deep_2013] makes them worth a second look for JSDM.
While one can build stochastic versions of other nonlinear regression methods as well [e.g. @hutchinson_incorporating_2011], the relative simplicity of the backpropagation algorithm for training neural networks [@murphy_machine_2012] makes them very appealing for exploratory research.

A neural net is a statistical model that makes its predictions by applying a series of nonlinear transformations to one or more predictor variables such as environmental measurements (Figure 3; Appendix B).
After a suitable transformation of the environmental data, a final operation performs logistic regressions in the transformed space to make predictions about each species' occurrence probability [cf @leathwick_using_2005].
Training a neural network entails simultaneously optimizing the parameters associated with these transformations to optimize the overall likelihood (Appendix C).

![**A** A generalized diagram for stochastic feed-forward neural networks that transform environmental variables into occurrence probabilities multiple species. The network's hidden layers perform a nonlinear transformation of the observed and unobserved ("latent") environmental variables; each species' occurrence probability then depends on the state of the final hidden layer in a generalized linear fashion. **B** The specific network used in this paper, with two hidden layers.  The inputs include Worldclim variables involving temperature and precipitation, as well as random draws from each of the latent environmental factors. These inputs are multiplied by a coefficient matrix and then nonlinearly transformed in the first hidden layer. The second hidden layer uses a different coefficient matrix to linearly transform its inputs down to a smaller number of variables (like Principal Components Analysis of the previous layer's activations). A third matrix of coefficients links each species' occurrence probability to each of the variables in this linear summary (like one instance of logistic regression for each species). The coefficients are all learned using a variant of the backpropagation algorithm.](figures/1/network-schematic.pdf)

Most neural networks' predictions are deterministic functions of their inputs.
Applied to SDM, this would mean that each species' occurrence probability would be fully specified by the small number of variables that ecologists happen to measure.
Mistnet's neural networks, in contrast, are *stochastic* [@neal_connectionist_1992; @tang_learning_2013; Appendix B], meaning that they allow species' occurrence probabilities to depend on unobserved environmental factors as well.
The true values of these unobserved factors are (by definition) not known, but one can still represent their *possible* values using samples from a probability distribution.
In the absence of any information about what these variables should represent, mistnet defaults to sampling them from standard normal distributions.
Depending on which values are sampled (i.e. on the possible states of the environment), the model could expect to see radically different kinds of species assemblages (Figure 1, Figure 3).

Inference can also proceed backward through a stochastic network: the presence (or absence) of one species provides information about the local environment, which can then be used to make better predictions about other species.
For example, suppose that a researcher has more data about the local distribution of waterfowl---which are of special interest to hunters and conservation groups---than about other species.
If waterfowl species are known to be present along a given route, then a mistnet model could infer that suitable habitat must have been available to them.
The model could then infer that the same habitat must have been available to other species, such as grebes and rails, with similar requirements.
These species' predicted occurrence probabilities should thus increase automatically wherever waterfowl have been detected.
Notably, the required correlations are automatically inferred from species' co-occurrence patterns, so the accuracy of these updated predictions does not depend closely on the user's ecological intuition about species' environmental tolerances.

As with most neural networks, a mistnet model's coefficients are initialized randomly, and then an optimization procedure attempts to climb the log-likelihood surface by iteratively adjusting the coefficients toward better values (i.e. gradient-based hill-climbing).
In mistnet models, these adjustments are calculated with a variant of the backpropagation algorithm suggested by @tang_learning_2013 (described in more detail in Appendix C).
The generalized expectation maximization procedure used in this variant alternates between inferring the states of the latent variables that produced the observed assemblages (via importance sampling) and updating the model's coefficients to make better predictions (via weighted backpropagation).
By iteratively improving the model's estimates of the latent environmental factors and of the parameters governing species' responses to them, this procedure will eventually bring the model---with probability one---to a local maximum likelihood estimate [@tang_learning_2013; @neal_view_1998].

In practice, most successful neural networks are regularized to avoid overfitting, meaning that they operate on a modified likelihood surface that favors reduced model complexity [@murphy_machine_2012].
In the mistnet package, regularization is formulated as prior distributions favoring smaller-magnitude parameter values over larger ones.
In Bayesian terms, this means that the model maximizes the model's posterior probability rather than the likelihood (maximum a posteriori estimation); in mathematically equivalent frequentist terms [@tibshirani_regression_1996; @murphy_machine_2012], mistnet maximizes a constrained or penalized likelihood.

The mistnet source code can be downloaded from  
https://github.com/davharris/mistnet/releases.

### A mistnet model for bird assemblages

Mistnet models can take a variety of forms, depending on the statistical or biological problems of interest.
The model used in these analyses, shown in Figure 3b, uses two hidden layers that transform the environmental data into a form that is suitable for a linear classifier; the final layer essentially performs logistic regression in this transformed space.
As discussed below, this structure is designed to improve the interpretability of the model, relative to other nonlinear SDMs.

Each hidden unit ("neuron") in the first layer is sensitive to a different axis of environmental variation (e.g. one neuron could respond positively to "cold and wet" environments, while another could respond to "hot and humid" environments).
The hidden units' responses are nonlinear (Appendix B), expressing the possibility that---for example---species might be more sensitive to a one-degree change in temperature from 25-26$^{\circ}$ C than to a change of the same magnitude from 19-20$^{\circ}$ C.

The second hidden layer collapses first layer’s description of the environment down to a smaller number of values (e.g. 15 in this analysis; Appendix D), using a linear transformation.
Thus, the network's structure ensures that each species' response to the environment can be described using a small number of coefficients (e.g., one for each of the 15 transformed environmental variables described in the second layer, plus an intercept term).
The small number of coefficients and the consistency of their ecological roles across species make mistnet models highly interpretable: the coefficients linking the second hidden layer to a given species' probability of occurrence essentially describe that species' responses to the leading principal components of environmental variation [cf @vincent_stacked_2010].
For comparison, the boosted regression tree SDMs used below [@elith_working_2008] have tens of thousands of coefficients per species, with entirely new interpretations for each new species' coefficients.

Apart from limiting the number of coefficients per species, two additional factors constrained the model's capacity for overfitting.
First, the coefficients in each layer were constrained using weak Gaussian priors, preventing any one variable from dominating the network.
Second, a very weak $\mathrm{Beta}(1.000001, 1.000001)$ prior was used to reduce the prevalence of overconfident predictions (|odds ratio| $> 10^6$).
The size of each layer and optimization details were chosen by cross-validation (see Appendix D for the settings that were evaluated, along with their cross-validated likelihoods).

### Existing models used for comparison

I compared mistnet's predictive performance with two machine learning techniques and with a linear JSDM.
Each technique is described briefly below; see Appendix D for each model's settings.

The first machine learning method I used for comparison, boosted regression trees (BRT), is among the most powerful techniques available for single-species SDM [@elith_novel_2006; @elith_working_2008].
I trained one BRT model for each species using the `gbm` package [@ridgeway_gbm_2013] and stacked them following the recommendations in @calabrese_stacking_2014.

I also used a deterministic neural network from the `nnet` package [@venables_modern_2002] as a baseline to assess the importance of mistnet's latent random variables.
This network shares some information among species (i.e. all species' occurrence probabilities depend on the same hidden layer), but like most other multi-species SDMs [@ferrier_using_2007; @leathwick_using_2005] it is not a JSDM and does not explicitly model co-occurrence [@clark_more_2013].

Finally, I trained a linear JSDM using the BayesComm package [@golding_phd_2013; @golding_bayescomm_2014] to assess the importance of mistnet's nonlinearities compared to a linear alternative that also models co-occurrence explicitly.

### Evaluating model predictions along test routes

I evaluated mistnet's predictions both qualitatively and quantitatively.
Qualitative assessments involved looking for patterns in the model's predictions and comparing them with ornithological knowledge (e.g. the AAB habitat classifications).

Each model was evaluated quantitatively on the test routes (red points in Figure 2) to assess its predictive accuracy out-of-sample.
Models were scored according to their predictive likelihoods, i.e. the probabilities they assigned to various scenarios observed in the test data.
Models with high likelihoods tend to produce realistic co-occurrence patterns, and should yield more biologically relevant insights about the processes underlying those patterns.
Models that overfit or underfit will have lower out-of-sample likelihoods, and drawing scientific conclusions from them could be unwise.
I tested each model's ability to make several kinds of predictions, ranging from the species level to predictions about the richness and composition of entire assemblages.
Models that assumed species were uncorrelated should see an exponential decay in their likelihoods as the number of species increases (since the probability of making correct predictions for a set of uncorrelated species equals the product of their individual probabilities), while BayesComm and mistnet should be able to simplify the problem for larger assemblages by using correlational information.

In addition to assessing the models' overall likelihoods, I also focused on their predictions about species richness by comparing the range of possible richness values they expected along each test route with what was actually observed.
For each model, I used the Poisson-binomial distribution [@hong_poibin_2013] to find confidence intervals for species richness, as described in @calabrese_stacking_2014.
The Poisson-binomial distribution (not to be confused with the better-known Poisson distribution for counting rare events) represents each species' occurrence as an independent Bernoulli trial with its own probability of success; the total number of successes determines the overall richness.
For the two JSDMs, I calculated the confidence intervals for the appropriate mixtures of Poisson-Binomial distributions (as estimated from 1000 independent Monte Carlo samples).

## Results and Discussion

### Mistnet's view of North American bird assemblages

I began by decomposing the variance in the mistnet's species-level predictions among routes (which varied in their climate values) and residual (within-route) variation (Appendix E).
On average, the residuals accounted for 30% of the variance in mistnet's predictions, suggesting that non-climate factors play a substantial role in habitat filtering.

If the non-climate factors mistnet identified were biologically meaningful, then there should be a strong correspondence between the 12 coefficients assigned to each species by mistnet and the AAB habitat classifications.
A linear discriminant analysis [LDA; @venables_modern_2002] demonstrated such a correspondence (Figure 4).
Mistnet's coefficients cleanly distinguished several groups of species by habitat association (e.g. "Grassland" species versus "Forest" species), though the model largely failed to distinguish "Marsh" species from "Lake/Pond" species and "Scrub" species from "Open Woodland" species.
These results indicate that the model has identified the broad differences among communities, but that it lacks some fine-scale resolution for distinguishing among types of wetlands and among types of partially-wooded areas.
Alternatively, perhaps these finer distinctions are not as salient at the scale of a 40-km transect or require more than two dimensions to represent.

![Each species' mistnet coefficients have been projected into a two-dimensional space by linear discriminant analysis (LDA), maximizing the spread between the six habitat types assigned to species by the Cornell Lab of Ornithology's All About Birds website. Mistnet cleanly separates "Grassland" species from "Forest" species, with "Scrub" and "Open Woodland" species representing intermediates along this axis of variation. "Marsh" and "Lake/Pond" species cluster together in the upper-left. Habitat classes with fewer than 15 species were omitted from this analysis.](figures/1/LDA.pdf)

While one might be able to produce a similar-looking scatterplot using ordination methods such as nonmetric multidimensional scaling [NMDS; @mccune_analysis_2002], the interpretation would be very different.
Species' positions in an ordination plots are chosen to preserve the multivariate geometry of the data and do not usually connect to any data-generating process or to a predictive model.
In Figure 4, by contrast, each species' coordinates describe the predicted slopes of its responses to two axes of environmental variation; these slopes could be used to make specific predictions about occurrence probabilities at new sites.
Likewise, deviations from these predictions could be used to falsify the underlying model, without the need for expensive permutation tests or comparison with a null model.
The close connection between model and visualization demonstrated in Figure 4 may prove especially useful in contexts where prediction and understanding are both important.

The environmental gradients identified in Figure 4 are explored further in Figure 5.
Figure 5A shows how the forest/grassland gradient identified by mistnet affects the model’s predictions for a pair of species with opposite responses to forest cover.
The model cannot tell *which* of these two species will be observed (since it was only provided with climate data), but the model has learned enough about these two species to tell that the probability of observing *both* along the same 40-km transect is much lower than would be expected if the species were uncorrelated.

![ **A.** The mistnet model has learned that Red-breasted Nuthatches (*Sitta canadensis*) and Horned Larks (*Eremophila alpestris*) have opposite responses to some environmental factor whose true value is unknown.
Based on these two species' biology, an ornithologist could infer that this unobserved variable is related to forest cover, with the Nuthatch favoring more forested areas and the Lark favoring more open areas.
The green asterisk marks the marginal expected probability of observing the two species.
**B.** The presence of a forest-dwelling Nashville Warbler (*Oreothlypis ruficapilla*) provides the model with a strong indication that the area is forested, increasing the weight assigned to Monte Carlo samples that are suitable for the Nuthatch and decreasing the weight assigned to samples that are suitable for the lark.
The model's updated expectations can be found at the head of the green arrow.
**C.** The Nashville Warbler's presence similarly suggests increased occurrence probabilities for a variety of other forest species (top portion of panel), and decreased probabilities for species associated with open habitat (bottom portion).
**D.** If a Redhead (*Aythya americana*) had been observed instead, the model would correctly expect to see more water-associated birds and fewer forest dwellers.
](figures/1/neighborly-advice.pdf)

Figure 5A reflects a great deal of uncertainty, which is appropriate considering that the model has no information about a crucial environmental variable (forest cover).
Often, however, additional information is available that could help resolve this uncertainty, and the mistnet package includes a built-in way to do so, as indicated in Figures 5B and 5C.
These panels show how the model is able to use a chance observation of a forest-associated Nashville Warbler (*Oreothlypis ruficapilla*) to indicate that a whole suite of other forest-dwelling species are likely to occur nearby, and that a variety of species that prefer open fields and wetlands should be absent.
Similarly, Figure 5D shows how the presence of a Redhead duck (*Aythya americana*) can inform the model that a route likely contains suitable habitat for waterfowl, marsh-breeding blackbirds, shorebirds, and rails (along with the European Starling and Bobolink, whose true wetland associations are somewhat weaker).
None of these inferences would be possible from a stack of disconnected single-species SDMs, nor would traditional ordination methods have been able to quantify the changes.

### Model comparison: species richness

Environmental heterogeneity plays an especially important role in determining species richness, which is often overdispersed relative to models' expectations [@ohara_species_2005].
Figure 6 shows that mistnet's predictions respect the heterogeneity one might find in nature: areas with a given climate could plausibly be either very unsuitable for most waterfowl (Anatid richness < 2 species) or much more suitable (Anatid richness > 10 species).
Under the independence assumption used for stacking SDMs, however, both of these scenarios would be ruled out (Figure 6A).

![The predicted distribution of species richness values one would expect to find based on predictions from mistnet and from the deterministic neural network baseline.
**A.** Anatid (waterfowl) species richness. **B.** Total species richness.
BRT's predictions (not shown) are similar to the baseline network, since neither one accounts for the effects of unmeasured environmental heterogeneity. In general, both networks' mean predictions are equally distant from the observed values, but only mistnet represents its uncertainty adequately.](figures/1/family-richness.pdf)

Stacking leads to even larger errors when predicting richness for larger groups, such as the complete set of birds studied here.
Models that stacked independent predictions consistently underestimated the range of biologically possible outcomes (Figure 6B), frequently putting million-to-one or even billion-to-one odds against species richness values that were actually observed.
These models' 95% confidence intervals were so narrow that half of the observed species richness values fell outside the predicted range.
The overconfidence associated with stacked models could have serious consequences in both management and research contexts if we fail to prepare for species richness values outside such unreasonably narrow bounds (e.g. expecting a reserve to protect 40-50 species even though it only supports 15).
Mistnet, on the other hand, was able to explore the range of possible non-climate environments to avoid these missteps: 90% of the test routes fell within mistnet's 95% confidence intervals, and the log-likelihood ratio decisively favored it over stacked alternatives.

### Model comparison: single species
Figure 7A compares the models' ability to make predictions for a single species across all the test routes (shown as the exponentiated expected log-likelihood).
While there was substantial variation among species, the two neural network models' predictions averaged more than an order of magnitude better than BRT's.
Moreover, these models' advantage over BRT was largest for low-prevalence species (linear regression of log-likelihood ratio versus log-prevalence; p = $3\cdot 10^{-4}$), which will often be of the greatest concern to conservationists.
The most likely reason for this improvement was a reduction in overfitting: while the overall model included complex nonlinear transformations, the number of degrees of freedom associated with any given species in the final logistic regression layer was modest (15 weights plus an intercept term).

![Relative predictive performance of the evaluated methods, as compared to BRT (mean +/- 95% CI, calculated from paired t-tests on the log-likelihood scale). **A.** Expected likelihood ratio for predictions about one species across 280 test-set routes.  **B.** Expected likelihood ratio when predicting species composition of a test route.](figures/1/likelihoods.pdf)

BayesComm's predictions were substantially worse than any of the machine learning methods tested, which I attribute mostly to its inability to learn nonlinear responses to the environment [@elith_novel_2006].
Adding quadratic terms or interaction terms [c.f. @austin_continuum_1985; @jamil_generalized_2013] would have led to severe overfitting for many rare species.
Even if one added a regularizer to the software to mitigate this problem, these extra pre-specified terms may still not provide enough flexibility to compete with modern nonlinear techniques.

Applying BayesComm to a large data set also highlighted one other area where mistnet appears to outperform existing JSDMs.
Despite its assumed linearity, the BayesComm model required 70,000 parameters, most of which served to to identify a distinct correlation coefficient between a single pair of species.
Tracing this many parameters through hundreds of Markov chain iterations routinely caused BayesComm to run out of of memory and crash, even after the code was modified to reduce its memory footprint.
Sampling long Markov chains over a dense, full-rank covariance matrix (as has apparently been done in all other JSDMs to date) thus appears to be a costly strategy with large assemblages.

### Model comparison: community composition

While making predictions about individual species is fairly straightforward with this data set (since most species have relatively narrow breeding ranges), community ecology is more concerned with co-occurrence and related patterns involving community composition [@chase_community_2003].
Mistnet was able to use the correlation structure of the data to reduce the number of independent bits of information needed to make an accurate prediction.
As a result, mistnet's route-level likelihood averaged 430 times higher than the baseline neural network's and 45,000 times higher than BRT's (Figure 7B).
BayesComm demonstrated a similar effect, but not strongly enough to overcome the low quality of its species-level predictions.

## Conclusion

The large discrepancy between the performance of linear and nonlinear methods shown in Figure 7A confirms previous results: accuracy in SDM applications requires the flexibility to learn about the functional form of species' environmental responses from the data [@elith_novel_2006].
Likewise, mistnet's large improvement over stacked models (Figure 6, Figure 7B) provides strong evidence that accurate assemblage-level predictions require accounting for unmeasured environmental heterogeneity---especially when reasonable confidence intervals are required.
Currently, mistnet appears to be the only software package that meets both of these criteria, providing both nonlinear responses to the environment and a method for dealing with assemblage-level responses to unobserved environmental heterogeneity.

Mistnet can also identify some of the same similarities among species that a skilled biologist would expect to find.
For taxa on the frontier of our knowledge, a model like mistnet could help guide the biologists to ask the best questions and organize their understanding by suggesting which species have similar habitat requirements---even when the factors controlling their occurrence are still unknown (cf. indirect gradient analysis).
Unlike with stacked methods, one can read this information directly from mistnet's coefficient tables with no more difficulty than interpreting a Principal Components Analysis.
Also, where most ordination techniques merely describe the multivariate geometry of an existing data matrix, mistnet's coefficients are directly tied to quantitative---and falsifiable---predictions about community structure in unobserved locations.
Nonlinear JSDMs should thus be able to take on a variety of roles in ecologists' toolboxes, providing a unified framework for summarizing community structure, developing forecasts, and evaluating hypotheses about community structure.

Future research should look for ways to use other forms of ecological knowledge about species to impose some structure on models coefficients and nudge the models toward more biologically reasonable predictions [@kearney_mechanistic_2009; @lankau_incorporating_2011; @kissling_towards_2012].
Such a research program could also be useful in other areas of predictive ecology [@pearse_predicting_2013].
JSDMs' ability to use asymmetrical or low-quality data sources to improve their predictions should also increase the value of low-effort data collection procedures such as short transects---especially since these data sources can be incorporated without the need for fitting a new model.

Finally, while it would be tempting to attribute JSDMs' correlation structure to species interactions, this approach may not be as fruitful as some authors have hoped.
The correlations are all driven indirectly via shared dependencies on latent variables, instead of the direct response of one species to another implied by species interactions.
@pollock_understanding_2014's covariance decomposition allows for some progress toward inferring interactions from JSDMs, but it would be much more straightforward to use a different approach (such as Markov random fields [@azaele_inferring_2010] or ensembles of classifier chains [@yu_multi-label_2011]) whose coefficients describe direct pairwise interactions much more explicitly.
Latent variable models are more appropriate for studies like this one at large spatial scales where direct species interactions will tend to be weaker and most of the variation is driven by environmental filtering and species' range limits.

Mistnet's accuracy, interpretability, and flexibility to work with opportunistic samples indicate that nonlinear JSDMs will be important in a variety of basic and applied contexts, from forecasting, to quantifying differences among species, to developing new insights about community structure.
Ecologists' models for these tasks need not be neural nets, but these analyses suggest that the most comprehensive and useful models will have many of the same features, such as latent random variables, nonlinearity, and low rank.

## Acknowledgements

This work benefitted greatly from discussions with A. Sih and his lab meeting group, M. L. Baskett, R. J. Hijmans, R. McElreath, J. H. Thorne, M. W. Schwartz, B. M. Bolker, R. E. Snyder, A. C. Perry, and C. S. Tysor, as well as comments from S. C. Walker and an anonymous reviewer.
It was funded by a Graduate Research Fellowship from the National Science Foundation, the UC Davis Center for Population Biology, and the California Department of Water Resources.
I gratefully acknowledge the field biologists that collected the BBS data, as well as the US Geological Survey, Cornell Lab of Ornithology, and Worldclim for making their data publicly available.

## Data Accessibility:
* All data sets used here are freely downloadable from their original sources.
* The mistnet source code is at https://github.com/davharris/mistnet and can be installed with the `install_github` function from the `devtools` package. The specific version used in this paper is at https://github.com/davharris/mistnet/releases/tag/v0.2.0


\newpage











# Estimating species interactions from observational data with Markov networks

David J. Harris

## Introduction

To the extent that nontrophic species interactions (such as competition) affect
community assembly, ecologists might expect to find signatures of these interactions in
species composition data [@macarthur_population_1958; @diamond_island_1975].
Despite decades of work and several major controversies, however
[@lewin_santa_1983; @strong_ecological_1984; @gotelli_swap_2003;
@connor_checkered_2013], existing methods for detecting competition's effects
on community structure are unreliable [@gotelli_empirical_2009]. In particular,
species' effects on one another can become lost in the complex web of direct and
indirect interactions in real assemblages. For example, the competitive
interaction between the two shrub species in Figure 1A can become obscured by
their shared tendency to occur in unshaded areas (Figure 1B). While ecologists
have long known that indirect effects can overwhelm direct ones at the landscape
level [@dodson_complementary_1970; @levine_competitive_1976], the vast majority of our methods for drawing
inferenes from observational data do not control for these effects
[e.g. @diamond_island_1975; @strong_ecological_1984; @gotelli_empirical_2009;
@veech_probabilistic_2013; @pollock_understanding_2014]. To the extent that
indirect interactions like those in Figure 1 are generally important
[@dodson_complementary_1970], existing methods will thus not generally provide
much evidence regarding species' direct effects on one another. The goal of this
paper is to resolve this long-standing problem.

![**Figure 1.** **A.** A small network of three competing species. The tree (top) tends not to
co-occur with either of the two shrub species, as indicated by the strongly
negative coefficient linking them. The two shrub species also compete with one
another, but more weakly (circled coefficient). **B.** In spite of the
competitive interactions between the two shrub species, their shared tendency to
occur in locations without trees makes their occurrence vectors positively
correlated (circled). **C.** Controlling for the tree species' presence with a
conditional method such as a partial covariance or a Markov network leads to
correct identification of the negative shrub-shrub interaction (circled).](figures/2/Figure_1.pdf)

While competition doesn't reliably reduce co-occurrence rates at the whole-landscape
level (as most of our methods assume), it nevertheless does leave a signal in
the data (Figure 1C). Specifically, after partitioning the data set into shaded
sites and unshaded sites, there will be co-occurrence deficits in each subset
that might not be apparent at the landscape level. More generally,
we can obtain much better estimates of the association between two species from
their conditional relationships (i.e. by controlling for other species in the
network) than we could get from their overall co-occurrence rates. This kind of
precision is difficult to obtain from null models, which begin with the
assumption that all the pairwise interactions are zero and thus don’t need to
be controlled for.  Nevertheless, null models have dominated this field for more
than three decades [@strong_ecological_1984; @gotelli_empirical_2009].

Following recent work by @azaele_inferring_2010 and @fort_statistical_2013, this
paper shows that Markov networks [undirected graphical models also known as
Markov random fields; @murphy_machine_2012] can provide a framework for
understanding the landscape-level consequences of pairwise species interactions,
and for detecting them from observed presence-absence matrices. Markov networks
have been used in many scientific fields in similar contexts for decades, from
physics [where nearby particles interact magnetically; @cipra_introduction_1987]
to spatial statistics [where adjacent grid cells have correlated values;
@harris_contact_1974; @gelfand_modelling_2005]. While community ecologists
explored some related approaches in the 1980's [@whittam_species_1981],
they used severe approximations that led to unintelligible results
[e.g. "probabilities" greater than one; @gilpin_factors_1982].

Below, I introduce Markov networks and show how they can be used to simulate
landscape-level data or to make exact predictions about the direct and
indirect consequences of possible interaction matrices. Then, using simulated
data sets where the "true" interactions are known, I compare this approach with
several existing methods. Finally, I discuss opportunities for extending the
approach presented here to other problems in community ecology, e.g. quantifying
the overall effect of species interactions on occurrence rates
[@roughgarden_competition_1983] and disentangling the effects of biotic versus
abiotic interactions on species composition [@kissling_towards_2012;
@pollock_understanding_2014].

## Methods

### Markov networks.
Markov networks provide a framework for translating back and forth between the
conditional relationships among species (Figure 1C) and the kinds of species
assemblages that these relationships produce. Here, I show how a set of
conditional relationships can be used to determine how groups of species
can co-occur. Methods for estimating conditional relationships from data are
discussed in the next section.

A Markov network defines the relative probability of observing a given vector of
species-level presences (1s) and absences (0s), $\vec{y}$, as

\centering

$p(\vec{y}; \alpha, \beta) \propto exp(\sum_{i}\alpha_i y_i + \sum_{i\neq j}\beta_{ij}y_i y_j).$

\raggedright
\setlength{\parindent}{1cm}

Here, $\alpha_{i}$ is an intercept term determining the amount that the presence
of species $i$ contributes to the log-probability of $\vec{y}$; it directly
controls the prevalence of species $i$. Similarly, $\beta_{ij}$ is the amount
that the co-occurrence of species $i$ and species $j$ contributes to the
log-probability; it controls the conditional relationship between two species,
i.e. the probability that they will be found together, after controlling for the
other species in the network (Figure 2A, Figure 2B). For example, $\beta_{ij}$
might have a value of $+2$ for two mutualists, indicating that the odds of
observing one species are $e^2$ times higher in sites where its partner is
present than in comparable sites where its partner is absent. Because the
relative probability of a presence-absence vector increases when
positively-associated species co-occur and decreases when negatively-associated
species co-occur, the model tends---all else equal---to produce assemblages that
have many pairs of positively-associated species and relatively few pairs of
negatively-associated species (exactly as an ecologist might expect).

![**Figure 2.**
**A.** A small Markov network with two species.  The abiotic environment favors
the occurrence of both species ($\alpha >0$), particularly species 2
($\alpha_2 > \alpha_1$). The  negative $\beta$ coefficient linking these two
species implies that they co-occur less than expected under independence.
**B.** Relative probabilities of all four possible presence-absence combinations
for Species 1 and Species 2. The exponent includes $\alpha_1$ whenever Species 1
is present ($y_1 = 1$), but not when it is absent ($y_1 = 0$).  Similarly, the
exponent includes $\alpha_2$ only when species $2$ is present ($y_2 = 1$), and
$\beta$ only when both are present ($y_1y_2 = 1$). The normalizing constant $Z$,
ensures that the four relative probabilities sum to 1.  In this case, $Z$ is
about 18.5.  **C.** We can find the expected frequencies of all possible
co-occurrence patterns between the two species of interest. **D.** If
$\beta_{12}$ equaled zero (e.g. if the species no longer competed for the same
resources), then the reduction in competition would allow each species to
increase its occurrence rate and the co-occurrence deficit would be eliminated.](figures/2/Figure_2.pdf)

Of course, if all else is *not* equal (e.g. Figure 1, where the presence of one
competitor is associated with release from another competitor), then species'
marginal association rates can differ from this expectation. Determining the
marginal relationships between species from their conditional interactions
entails summing over the different possible assemblages (Figure 2B). This
becomes intractable when the number of possible assemblages is large, though
several methods beyond the scope of this paper can be employed to keep the
calculations feasible [@lee_learning_2012; @salakhutdinov_learning_2008].
Alternatively, as noted below, some common linear and generalized linear methods
can also be used as computationally efficient approximations to the full network
[@lee_learning_2012; @loh_structure_2013].

### Estimating $\alpha$ and $\beta$ coefficients from presence-absence data.
In the previous section, the values of $\alpha$ and $\beta$ were known and the
goal was to make predictions about possible species assemblages. In
practice, however, ecologists will often need to estimate the parameters from
an observed co-occurrence matrix (i.e. from a matrix of ones and zeros
indicating which species are present at which sites). When the number of species
is reasonably small, one can compute exact maximum likelihood estimates for all
of the $\alpha$ and $\beta$ coefficients given a presence-absence matrix by
optimizing $p(\vec{y}; \alpha, \beta)$. Fully-observed Markov networks like the
ones considered here have unimodal likelihood surfaces [@murphy_machine_2012],
ensuring that this procedure will always converge on the global maximum. This
maximum represents the unique combination of $\alpha$ and $\beta$ coefficients
that would be expected to produce exactly the observed co-occurrence frequencies
on average [i.e. maximizing the likelihood matches the sufficient statistics of the model distribution
to the sufficient statistics of the data; @murphy_machine_2012]. I used the
rosalia package [@harris_rosalia_2015] for the R programming language
[@r_core_team_r_2015] to optimize the Markov network parameters. The package was
named after Santa Rosalia, the patron saint of biodiversity, whose supposedly
miraculous healing powers played an important rhetorical role in the null model
debates of the 1970's and 1980's [@lewin_santa_1983].

### Simulated landscapes.
In order to compare different methods, I simulated two sets of landscapes using
known parameters. The first set included the three competing species shown in
Figure 1. For each of 1000 replicates, I generated a landscape with 100 sites by
sampling from a probability distribution defined by the figure's interaction
coefficients (Appendix 1). Each of the methods described below was then
evaluated on its ability to correctly infer that the two shrub species competed
with one another, despite their frequent co-occurrence.

I also simulated a second set of landscapes using a stochastic community model
based on generalized Lotka-Volterra dynamics, as described in Appendix 2. In
these simulations, each species pair was randomly assigned to either compete for
a portion of the available carrying capacity (negative interaction) or to act as
mutualists (positive interaction).  Here, mutualisms operate by mitigating the
effects of intraspecific competition on each partner's death rate.  For these
analyses, I simulated landscapes with up to 20 species and 25, 200, or 1600
sites (50 replicates per landscape size; see Appendix 2).

### Recovering species interactions from simulated data.

I compared seven techniques for determining the sign and strength of the
associations between pairs of species from simulated data (Appendix 3).
First, I used the rosalia package [@harris_rosalia_2015] to fit Markov newtork
models,  as described above. For the analyses with 20 species, I added a very
weak logistic prior distribution on the $\alpha$ and $\beta$ terms with scale 2
to ensure that the model estimates were always finite. The bias introduced by
this prior should be small: the 95% credible interval on $\beta$ only requires
that one species' effect on the odds of observing a different species to be less
than a factor of 1500 (which is not much of a constraint). The logistic
distribution was chosen because it is convex and has a similar shape to the
Laplace distribution used in LASSO regularization (especially in the tails), but
unlike the Laplace distribution it is differentiable everywhere and does not
force any estimates to be exactly zero. To confirm that this procedure produced
stable estimates, I compared its estimates on 50 bootstrap replicates
(Appendix 4).

I also evaluated six alternative methods: five from the existing literature,
plus a novel combination of two of these methods. The first alternative interaction
metric was the sample correlation between species' presence-absence vectors,
which summarizes their marginal association.  Next, I used partial correlations,
which summarize species' conditional relationships [@albrecht_spatial_2001;
@faisal_inferring_2010]. In the context of non-Gaussian data, the partial
correlation can be thought of as a computationally efficient approximation to
the full Markov network model [@loh_structure_2013]. This sort of model is very
common for estimating relationships among genes and gene products
[@friedman_sparse_2008]. Because partial correlations are undefined for
landscapes with perfectly-correlated species pairs, I used a regularized
estimate based on James-Stein shrinkage, as implemented in the corpcor package’s
`pcor.shrink` function with the default settings [@schafer_corpcor_2014].

The third alternative, generalized linear models (GLMs), can also be
thought of as a computationally efficient approximation to the Markov
network [@lee_learning_2012].  Following @faisal_inferring_2010,  I fit
regularized logistic regression models [@gelman_weakly_2008] for each species,
using the other species on the landscape as predictors. To avoid the
identifiability problems associated with directed cyclic graphs
[@schmidt_modeling_2012], I then symmetrized the relationships within species
pairs via averaging.

The next method, described in @gotelli_empirical_2009, involved
simulating new landscapes from a null model that retains the row and column
sums of the original matrix [@strong_ecological_1984]. I used the $Z$-scores
computed by the Pairs software described in @gotelli_empirical_2009 as my null
model-based estimator of species interactions.

The last two estimators used the latent correlation matrix estimated by the
BayesComm package [@golding_bayescomm_2015] in order to evaluate the recent
claim that the correlation coefficients estimated by "joint species distribution
models" provide an accurate assessment of species’ pairwise interactions
[@pollock_understanding_2014; see also @harris_generating_2015]. In addition to
using the posterior mean correlation [@pollock_understanding_2014], I also used
the posterior mean *partial* correlation, which might be able to control for
indirect effects.

### Evaluating model performance.
For the simulated landscapes based on Figure 1, I assessed whether each method's
test statistic indicated a positive or negative relationship between the two
shrubs (Appendix 1). For the null model (Pairs), I calculated statistical
significance using its $Z$-score. For the Markov network, I used the Hessian
matrix to generate approximate confidence intervals and noted whether these
intervals included zero.

I then evaluated the relationship between each method's estimates and the "true"
interaction strengths among all of the species pairs from the larger simulated
landscapes. This determined which of the methods provide a consistent way to know
how strong species interactions are---regardless of which species were present
in a particular data set or how many observations were taken. Because the
different methods mostly describe species interactions on different scales
(e.g. correlations versus $Z$ scores versus regression coefficients), I used
linear regression through the origin to rescale the different estimates produced
by each method so that they had a consistent interpretation. After rescaling
each method’s estimates, I calculated squared errors between the scaled
interaction estimates and “true” interaction values across all the simulated
data sets. These squared errors determined the proportion of variance explained
for different combinations of model type and landscape size (compared with a
null model that assumed all interaction strengths to be zero).

## Results

### Three species.
As shown in Figure 1, the marginal relationship between the two shrub species
was positive---despite their competition for space at a mechanistic level---due
to indirect effects of the dominant tree species. As a result, the correlation
between these species was positive in 94% of replicates, and the
randomization-based null model falsely reported positive associations 100% of
the time. Worse, more than 98% of these false conclusions were statistically
significant. The partial correlation and Markov network estimates, on the other
hand, each correctly isolated the direct negative interaction between the shrubs
from their positive indirect interaction 94% of the time (although the
confidence intervals overlapped zero in most replicates).

### Twenty species.
Despite some variability across contexts (Figure 3A), the four methods that
controlled for indirect effects clearly performed the best: the Markov network
explained the largest portion of the variance in the "true" interaction
coefficients (35% overall), followed by the generalized linear models (30%),
partial correlations from the raw presence-absence data (28%), and partial
correlations from BayesComm, the joint species distribution model (26%).  The
benefit of choosing the full Markov network over the other three methods was
largest on the smaller landscapes, which are also the ones that are most
representative of typical analyses in this field [@gotelli_empirical_2009].

![**Figure 3.**
**A.** Proportion of variance in interaction coefficients explained by each
method versus number of sampled locations.
**B.** The $Z$-scores produced by the null model ("Pairs") for each pair of
species can be predicted using the correlation between the presence-absence
vectors of those same species and from the number of sites on the landscape.](figures/2/performance.pdf)

The three methods that did not attempt to control for indirect interactions all
explained less than 20% of the variance. Of these, the sample correlation matrix
based on the raw data performed the best (19%), followed by the null model
(15%) and BayesComm's correlation matrix (11%). Although these last three
methods had different $R^2$ values, there was a close mapping among
their estimates (especially after controlling for the size of the simulated
landscapes; Figure 3B).  This suggests that the effect sizes from the null model
(and, to a lesser extent, the correlation matrices from joint species
distribution models) only contain noisy versions of the same information that
could be obtained more easily and interpretably by calculating correlation
coefficients between species' presence-absence vectors.

Bootstrap resampling indicated that the above ranking of the different methods
was robust (Appendix 3). In particular, the 95% confidence interval of the
bootstrap distribution indicated that the Markov network's overall $R^2$ value
was between 14 and 18 percent higher than the second-most effective
method (generalized linear models) and between 2.12 and 2.38 times higher than
could be achieved by the null model (Pairs).  Bootstrap resampling of a 200-site
landscape also confirmed that the rosalia package's estimates of species'
conditional relationships were robust to sampling variation for reasonably-sized
landscapes (Appendix 4).

## Discussion

The results presented above show that Markov networks can reliably recover
species' pairwise interactions from observational data, even for cases where
a common null modeling technique reliably fails. Specifically, Markov networks
were successful even when direct interactions were largely overwhelmed by
indirect effects (Figure 1). For cases where fitting a Markov network is
computationally infeasible, these results also indicate that partial covariances
and generalized linear models (the two methods that estimated conditional
relationships rather than marginal ones) can both provide useful approximations.
The partial correlations' success on simulated data may not carry over to real
data sets, however; @loh_structure_2013 show that the linear approximations can
be less reliable in cases where the true interaction matrix contains more
structure (e.g. guilds or trophic levels). Similarly, the approximation involved
in using separate generalized linear models for each species can occasionally
lead to catastrophic overfitting with small-to-moderate sample sizes
[@lee_learning_2012]. For these reasons, it will usually be best to fit a Markov
network rather than one of the alternative methods when one’s computational
resources allow it.

It’s important to note that none of these methods can identify the exact nature
of the pairwise interactions [e.g. which species in a positively-associated
pair is facilitating the other; @schmidt_modeling_2012], particularly when real
pairs of species can reciprocally influence one another in multiple ways
simultaneously [@bruno_inclusion_2003]; with compositional data, there is only
enough information to provide a single number describing each species pair.
To estimate asymmetric interactions, such as commensalism or predation,
ecologists would need other kinds of data, as from time series, behavioral
observations, manipulative experiments, or natural history. These other sources
of information could also be used to augment the likelihood function with an
informative prior distribution, which could lead to better results on some real
data sets than was shown in Figure 3A.

Despite their limitations, Markov networks have enormous potential to improve
ecological understanding. In particular, they are less vulnerable than some
of the most commonly-used methods to mistakenly identifying positive species
interactions between competing species, and can make precise statements about
the conditions where indirect interactions will overwhelm direct ones. They also
provide a simple answer to the question of how competition should affect a
species' overall prevalence, which was a major flashpoint for the null model
debates in the 1980’s [@roughgarden_competition_1983; @strong_ecological_1984].
Equation 1 can be used to calculate the expected prevalence of a species in the
absence of biotic influences [$\frac{e^\alpha}{1 + e^{\alpha}}$; @lee_learning_2012].
Competition's effect on prevalence in a Markov network can then be calculated by
subtracting this value from the observed prevalence (cf Figure 2D). This kind of
insight would have been difficult to obtain without a generative model that
makes predictions about the consequences of species interactions; null models
(which presume *a priori* that interactions do not exist) have no way to make
such predictions.

Markov networks---particularly the Ising model for binary networks---have been
studied for nearly a century [@cipra_introduction_1987], and the models'
properties, capabilities, and limits are well-understood in a
huge range of applications. Using the same framework for species interactions
would thus allow ecologists to tap into an enormous set of existing
discoveries and techniques for dealing with indirect effects, stability, and
alternative stable states. Numerous other extensions are possible: for example,
the states of the interaction network can be modeled as a function of
the local abiotic environment [@lee_learning_2012], which would provide a
rigorous and straightforward approach to the difficult and important task of
incorporating whole networks of biotic interactions into species distribution
models [@kissling_towards_2012; @pollock_understanding_2014], leading to a
better understanding of the interplay between biotic and abiotic effects on
community structure. There are even methods [@whittam_species_1981;
@tjelmeland_markov_1998] that would allow one species to affect the sign or
strength of the relationship between two other species, tipping the balance
between facilitation and exploitation [@bruno_inclusion_2003].

Finally, the results presented here have important implications for
ecologists' continued use of null models for studying species interactions. Null
and neutral models can be useful for clarifying our thinking about the numerical
consequences of species' richness and abundance patterns
[@harris_occupancy_2011; @xiao_strong_2015], but deviations from a particular
null model must be interpreted with care [@roughgarden_competition_1983]. Even
in small networks with three species, it may simply not be possible to implicate
individual species pairs or specific ecological processes like competition by
rejecting a general-purpose null [@gotelli_empirical_2009], especially when the
test statistic is effectively just a correlation coefficient (Figure 3B).
Simultaneous estimation of multiple ecological parameters seems like a much more
promising approach: to the extent that the models' relative performance on real
data sets is similar to the range of results shown in Figure 3A, scientists in
this field could often double their explanatory power by switching from null
models to Markov networks (or increase it substantially with linear or
generalized linear approximations). Regardless of the methods ecologists
ultimately choose, controlling for indirect effects could clearly improve our
understanding of species' direct effects on one another and on community
structure.

## Acknowledgements:
This research was funded by a Graduate Research Fellowship from the US
National Science Foundation and benefited greatly from discussions with A.
Sih, M. L. Baskett, R. McElreath, R. J. Hijmans, A. C. Perry, and C. S. Tysor.
Additionally, A. K. Barner, E. Baldridge, E. P. White, D. Li, D. L. Miller, N.
Golding, N. J. Gotelli, C. F. Dormann, and two anonymous reviewers provided
very helpful feedback on the text.

\setstretch{1.1}
\setlength{\parskip}{12pt}
\setlength{\parindent}{0em}
\setlength{\leftskip}{0em}

# References
