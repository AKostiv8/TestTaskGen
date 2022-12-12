# 1. To launch the app run `app.R` file

# 2. Suggestions:
### 2.1) Creating a user-friendly table with visualization based on requirements and a defined end-user road is a great opportunity. (e.g. https://glin.github.io/reactable/articles/shiny-demo.html)
### 2.2) Complex calculations are a bottleneck for the `R/Shiny` framework, so in the context of the large-scale dashboard, I would suggest creating an external `API` with the calculations (`R, Python or even Julia` can be considered for this reason) to avoid the app overloading. 
### 2.3) Based on point `2.2` the app flow would have the next format `API (R/Python)` -> `Dashboard (RShiny/PyShiny or for the complex dashboards -> web stack like JS/NODEJS/REACTJS/etc.)`
