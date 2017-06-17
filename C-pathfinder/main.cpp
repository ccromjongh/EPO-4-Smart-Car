#include <iostream>
#include <vector>
#include <cmath>
#include <cstdlib>
#include <cstring>

using namespace std;

#define MATLAB_IS_AN_IDIOT true

#if (MATLAB_IS_AN_IDIOT)
    #include <mex.h>
    #define M_PI 3.141592653589793238462643383279502884197169399375105820974944592307816406286
    #define M_PI_2 (M_PI/2)
    #define M_PI_4 (M_PI/4)
#endif

#define RADIUS 0.10
#define TWO_PI (2*M_PI)
#define END_TOLLERANCE 0.1
#define END_ANGLE_TOLLERANCE (M_PI_4/2)    // 45/2 = 22.5 deg
#define ENFORCE_ANGLE false
//#define ANGLE_LIMIT (M_PI_4/6)             // 45/6 = 7.5 deg
#define ANGLE_LIMIT 0.1210640396             // minimum diameter of 1.65 meter
#define ANGLE_DIVISIONS 6

#define RADIUS_MULTIPLIER 100
#define OBSTACLE_RADIUS 0.4

class Node
{
public:
    double x, y, end_radius = 0;
    unsigned int estm_cost, path_cost, face_dir = 1, steps = 0;
    Node *parent;
    Node(Node *parent, double x_coord, double y_coord, unsigned int path_cost = 0);
    Node *createChild(unsigned int relative_angle);
    void set_abs_angle(double angle);
    const double get_rel_angle(), get_diff_angle(), get_abs_angle();
	unsigned int abs_ang_360;
	int rel_ang_360, diff_ang_360;

private:
    double rel_angle = 0.0, diff_angle = 0.0, abs_angle;
    void set_rel_angle();
};

class PathNode
{
public:
    Node *mapNode;
    struct PathNode *next;
    struct PathNode *prev;
    PathNode(Node *mapNode, unsigned int cost = 0);
    void before(PathNode *insert), after(PathNode *insert);
};

struct Obstacle {
    double x = 0, y = 0;
};

double start_x = -0.235, start_y = -1.325, start_angle = -M_PI_2;
double end_x = 2.38, end_y = -0.7, end_angle = M_PI_2;
double field_x_min = -2.5, field_x_max = 2.5, field_y_min = -2.5, field_y_max = 2.5;
unsigned long nodesChosen = 0, nodesLookedAt = 0, maxStepsTillNow = 0;

Node *start_node, *end_node;

vector<double> angles;
vector<Obstacle> obstacles;

unsigned int costFunction (Node *current);
void printRoute(PathNode *destination);

/*vector<int>* linSpace(int16_t lower, int16_t upper) {
    int length = abs(upper - lower);
    int *arr = new int[length];
    int *arr2 = (int *) malloc(sizeof(int) * length);
    int arr3[length];
    vector<int> *arr4 = new vector<int> (length);

    for (int i = 0; i < length; ++i) {
        arr[i] = lower + i;
        arr2[i] = lower + i;
        arr3[i] = lower + i;
        (*arr4)[i] = lower + i;
    }

    std::cout << "Array[5] = " << arr[5] << std::endl;

    delete [] arr2;
    free(arr);
    return arr4;
}*/

unsigned int addAngles (unsigned int source, int addition) {
    int sum = (int) (source + addition);
    while (sum < 0) {
        sum += 360;
    }
    while (sum > 360) {
        sum -= 360;
    }
    return (unsigned int) sum;
}

double addAngles (double source, double addition) {
    double sum = source + addition;
    while (sum < -M_PI) {
        sum += TWO_PI;
    }
    while (sum > M_PI) {
        sum -= TWO_PI;
    }
    return sum;
}

double calcRadius (double x, double y) {
    return sqrt(pow(x, 2) + pow(y, 2));
}

double calcRadius (Node *source, Node *destination) {
    return calcRadius(source->x - destination->x, source->y - destination->y);
}

Node::Node(Node *parent, double x_coord, double y_coord, unsigned int path_cost) {
    //Node *creation = (Node *) malloc(sizeof(Node));
    x = x_coord;
    y = y_coord;

    if (parent != NULL) {
        this->parent = parent;

        double dx = x - parent->x;
        double dy = y - parent->y;

        // Just for a better view of how far in the path we are
        steps = parent->steps + 1;

        /*double angle = ((atan2(dy, dx)) / (2.0 * M_PI) + 0.5) * 360;
        abs_angle = (unsigned int) angle;
        rel_angle = addAngles(abs_angle, -parent->abs_angle);*/

        set_abs_angle(atan2(dy, dx));
        set_rel_angle();
    } else {
        rel_ang_360 = 0;
        diff_ang_360 = 0;
        this->parent = nullptr;
    }

    if (path_cost) {
        estm_cost = path_cost;
        path_cost = 0;
    } else if (start_node && end_node) {
        costFunction(this);

        // If this is not the start or end node, calculate the distance to the end node
        end_radius = calcRadius(x - end_node->x, y - end_node->y);
    }
}

Node *Node::createChild(unsigned int relative_angle) {
    double _x = x + RADIUS * cos(abs_angle + relative_angle);
    double _y = y + RADIUS * sin(abs_angle + relative_angle);

    Node *obj = new Node(this, _x, _y, estm_cost);
    obj->estm_cost = costFunction(obj);

    return obj;
}

void Node::set_abs_angle(double angle) {
    // Normalize angle
    abs_angle = addAngles(angle, 0.0);

    // Invert and add a half pi to the angle to get the zero point to the north
    double conv_angle = -abs_angle + M_PI_2;
    // If we are below zero, add two pi to get it positive
    if (conv_angle < 0) {
        conv_angle += TWO_PI;
    }
    abs_ang_360 = (unsigned int) ((conv_angle / TWO_PI) * 360);
}

void Node::set_rel_angle() {
    // The change in direction relative to the parent Node
    rel_angle = addAngles(parent->abs_angle, -abs_angle);

    if (abs(rel_angle) < 0.0000000001) {
        rel_angle = 0.0;
    }

    // The change in relative angle. This is how much steering action is needed
    diff_angle = addAngles(-parent->rel_angle, rel_angle);

    rel_ang_360 = (int) ((rel_angle / TWO_PI) * 360);
    diff_ang_360 = (int) ((diff_angle / TWO_PI) * 360);
}

const double Node::get_rel_angle() {
    return rel_angle;
}

const double Node::get_diff_angle() {
    return diff_angle;
}

const double Node::get_abs_angle() {
    return abs_angle;
}

PathNode::PathNode(Node *mapNode, unsigned int cost) {
    this->mapNode = mapNode;
    this->next = nullptr;
    this->prev = nullptr;
    if (cost) {
        this->mapNode->estm_cost = cost;
    } else {
        costFunction(this->mapNode);
    }
}

void PathNode::before(PathNode *insert) {
    insert->prev = this->prev;  // Put node before original as previous in the insert PathNode
    insert->next = this;        // And set the next ptr to the node being prepended to
    prev = insert;              // Set previous of the original node to the insert

    // If there is a node before the insert, set the next link to the insert
    if (insert->prev) { insert->prev->next = insert; }
}

void PathNode::after(PathNode *insert) {
    insert->prev = this;        // Put original as previous in the insert PathNode
    insert->next = this->next;  // And set the next ptr to the node that came after the original
    next = insert;              // Set next of the original node to the insert

    // If there is a node after the insert, set the previous link to the insert
    if (insert->next) { insert->next->prev = insert; }
}


vector<double> linSpace(double lower, double upper, int divisions = 1) {
    int abs_div_num = divisions * 2;
    double range = abs(upper - lower);
    double stepsize = range / abs_div_num;
    vector<double> arr (abs_div_num + 1);

    for (int i = 0; i <= abs_div_num; ++i) {
        arr[i] = lower + (i * stepsize);
    }

    return arr;
}



void placeSorted (PathNode **firstNode, PathNode *insert) {
    PathNode *ptr;
    ptr = *firstNode;

    // If this is the very first item, just install it as the list
    if (*firstNode == NULL)
    {
        *firstNode = insert;
        return;
    }


    // If the insert node is cheaper, or of equal than the first node
    // When equal, we need to favour the newest node for speed purposes. Otherwise, when two paths have
    // (near) equal cost, the algorithm will oscillate between the paths
    if (insert->mapNode->estm_cost <= ptr->mapNode->estm_cost)
    {
        // Place if before the starting node
        (*firstNode)->before(insert);
        *firstNode = insert;
        return;
    }

    while (ptr->next != NULL)
    {
        // If the insert node cost is lower than the next item
        if (insert->mapNode->estm_cost <= ptr->next->mapNode->estm_cost)
        {
            // Insert it before that item in the linked list
            ptr->after(insert);
            return;
        }
        // Else, take a look at the next item in the list
        ptr = ptr->next;
    }

    // If the node is more expensive than all others, place it at the end of the row
    ptr->after(insert);
}

double end_angle_difference(Node *compare) {
    double first = abs(addAngles(compare->get_abs_angle(), -end_node->get_abs_angle()));
    double second = abs(addAngles(compare->get_abs_angle() + M_PI, -end_node->get_abs_angle()));
    double least = min(first, second);
    return least;
}



unsigned int costFunction (Node *current) {
    unsigned int estm_cost = 0;
    unsigned int path_cost = (unsigned int) (RADIUS * RADIUS_MULTIPLIER * 0.95);

    // Add estimation cost for distance to the target
    double radius = calcRadius(current,  end_node);
    double virt_x = current->x + 0.3 * radius * cos(current->get_abs_angle());
    double virt_y = current->y + 0.3 * radius * sin(current->get_abs_angle());
    double virt_distance = calcRadius(end_node->x - virt_x, end_node->y - virt_y) + 0.3 * radius;
    estm_cost += (virt_distance * RADIUS_MULTIPLIER);

    // If we have a parent, add the cost of the steps already taken to the path length cost
    if (current->parent)
    {
        path_cost += current->parent->path_cost;
    }

    // Add some cost for the relative angle, because we don't want unnecessary steering
    path_cost += abs(current->get_rel_angle()) * 20;

    // Add some cost for the differential angle, because we want to change the steering direction as little as possible
    path_cost += pow(abs(current->get_diff_angle()), 2) * 40;

#if (ENFORCE_ANGLE)
    //if (radius < 1.0) {
        double test = log10(radius);
        double test2 = log10(0.027);
        //double angle_cost = -50 * end_angle_difference(current) * log10(radius);
        //angle_cost = 30 * end_angle_difference(current) * (1.0-radius);
        double angle_cost = 10 * end_angle_difference(current) / pow(radius, 0.25);
        estm_cost += angle_cost;
    //}
#endif

    // Estimation cost should include history of the path
    estm_cost += path_cost;

    // Set calculated properties
    current->estm_cost = estm_cost;
    current->path_cost = path_cost;

    // Return the estimation
    return estm_cost;
}

bool checkObstacles(double x, double y) {
    for (int i = 0; i < obstacles.size(); ++i) {
        if (calcRadius(obstacles[i].x - x, obstacles[i].y - y) < OBSTACLE_RADIUS) {
            //printf("Obstacle check returns false\n");
            return false;
        }
    }
    //printf("Obstacle check returns true\n");
    return true;
}

bool checkPerimeter(double x, double y) {
    if (x > field_x_min && x < field_x_max && y > field_y_min && y < field_y_max) {
        //printf("Perimeter returns true\n");
        return true;
    }
    //printf("Perimeter returns false\n");
    return false;
}

PathNode *seekPath() {
    PathNode *startPathNode, *openList, *working, *pathNodeOption;
    startPathNode = new PathNode(start_node);
    Node *nodeOption;
	double distance_to_target;

    openList = NULL;
    working = startPathNode;

    // Keep finding nodes, until we got sufficiently close to the end-node
    while (true)
    {
        for (int j = 0; j < (2*ANGLE_DIVISIONS + 1); ++j) {
            double angle = angles[j] + working->mapNode->get_abs_angle();
            double _x = working->mapNode->x + RADIUS * cos(angle);
            double _y = working->mapNode->y + RADIUS * sin(angle);

            //printf("I hate MATLAB; j = %d\t_x = %.2lf\t_y = %.2lf\n", j, _x, _y);

            if (checkObstacles (_x, _y) && checkPerimeter(_x, _y)) {
                nodeOption = new Node(working->mapNode, _x, _y);
                pathNodeOption = new PathNode(nodeOption);
                nodesLookedAt++;

                if (nodesLookedAt > 25000) { goto NoPath; }
                /*if (calcRadius(nodeOption, end_node) <= END_TOLLERANCE) {
                    goto reachedEnd;
                }*/

                placeSorted(&openList, pathNodeOption);
            }
        }

        if (openList == NULL)
        {
            NoPath: printf("\n! No path could be found !\n\nLooked at %d nodes, chose %d, but it didn't work out\n", nodesLookedAt, nodesChosen);
            return NULL;
        }

        distance_to_target = calcRadius(openList->mapNode, end_node);
        if (openList && distance_to_target <= END_TOLLERANCE) {
            #if (ENFORCE_ANGLE)
                double tollerance_compare = end_angle_difference(openList->mapNode);
                if (tollerance_compare < END_ANGLE_TOLLERANCE) {
                    goto reachedEnd;
                }
            #else
                goto reachedEnd;
            #endif
        }

        nodesChosen++;
        if (working->mapNode->steps > maxStepsTillNow) {
            maxStepsTillNow = working->mapNode->steps;
        }

        if (openList->mapNode->steps >= maxStepsTillNow - 2) {
            //cout << "I like turtles" << endl;
        }

        // FIXME: Closed list is not strictly implemented, this leads to a memory leak
        // Free the working PathNode, since we only need the Node to  track it back
        free(working);

        // Set Node to spawn new Nodes from to the head of the open list, since that Node is the cheapest
        working = openList;

        //removeFromList(openList);
        openList = openList->next;
    }

    reachedEnd: cout << "Found a path, yay!" << endl;

    // Cleanup of all objects
    //deleteList(working);
    //deleteList(openList); //Not needed because of working = openList;
    //resetMap(false, false);
    return openList;
}

void printRoute(PathNode *destination) {
	Node *ptr = destination->mapNode;
	
	do {
        printf("Step = %d\tx = %.2f m\ty = %.2f m\trel angle = %d deg\tdiff angle = %d deg\tabs angle = %d deg\n",
               ptr->steps, ptr->x, ptr->y, ptr->rel_ang_360, ptr->diff_ang_360, ptr->abs_ang_360);
		//cout << "Advance with a relative angle of " << ptr->rel_ang_360 << " deg" << endl;
	} while ((ptr = ptr->parent) != nullptr);


    // Do it again with MATLAB ish notation
    ptr = destination->mapNode;
    printf("\nError at destination: %.3f cm\n", (ptr->end_radius * 100));

    char x_buffer[500], y_buffer[500], *x_end = x_buffer, *y_end = y_buffer;
    bool first = true;

    do {
        if (first) { first = false; }
        else {
            strcpy(x_end, ", ");
            strcpy(y_end, ", ");
            x_end += 2;
            y_end += 2;
        }
        x_end += sprintf(x_end, "%.3f", ptr->x);
        y_end += sprintf(y_end, "%.3f", ptr->y);
    } while ((ptr = ptr->parent) != nullptr);

    printf("\nMATLAB code:\n\nx = [%s];\ny = [%s];"
                   "\nplot(x, y);\naxis([-2.5 2.5 -2.5 2.5]); pbaspect([1 1 1]);"
                   "\ntitle('KITT navigation using vertex pathfinding');"
                   "\nxlabel('X axis (m)'); ylabel('Y axis (m)');\n\n", x_buffer, y_buffer);
}

PathNode *backtrace (PathNode *destination, size_t *pathLength = nullptr)
{
    printf("Do I even reach this point?\n");
	size_t nNodes = 0;
    Node *ptr = destination->mapNode;
    PathNode *list = new PathNode(ptr);
    printf("This is fine\n");

    // Trace to parent, and add it before the current item in the list
    while ((ptr = ptr->parent) != NULL)
    {
        list->prev = new PathNode(ptr);
        list->prev->next = list;
        list = list->prev;
		nNodes++;
    }

    printf("We still good?\n");

	if (pathLength) {
		*pathLength = nNodes;
	}

    return list;
}

int main() {
    // Set up angle array for the pathfinder to chose from
    angles = linSpace(-ANGLE_LIMIT, ANGLE_LIMIT, ANGLE_DIVISIONS);

    // Create start and end node
    start_node = new Node(NULL, start_x, start_y, 0);
    end_node = new Node(NULL, end_x, end_y, 0);

    // Set correct orientation of start and end node
    start_node->set_abs_angle(start_angle);
    start_node->estm_cost = costFunction(start_node);
    end_node->set_abs_angle(end_angle);


    PathNode *route = seekPath();

    if (route) {
        printRoute(route);
    }

    std::cout << "End of program :'(" << std::endl;
    return 0;
}

#if (MATLAB_IS_AN_IDIOT)

/** This is the function that MATLAB will use when calling the .mex file
 *
 *  C/MEX   Meaning                                             MATLAB equivalent
 *
 *  nlhs    Number of output variables                          nargout
 *  plhs    Array of mxArray pointers to the output variables   varargout
 *  nrhs    Number of input variables                           nargin
 *  prhs    Array of mxArray pointers to the input variables    varargin
 *
 *  MATLAB syntax: [x_arr, y_arr, ang_arr] = main([start_x, start_y], start_angle, [end_x, end_y], [field_x_min field_x_max field_y_min field_y_max], obstacles)
 *
 **/

#define MX_NUM_EL(P) mxGetNumberOfElements(P)
#define IS_REAL_DOUBLE(P) (!mxIsComplex(P) && !mxIsSparse(P) && mxIsDouble(P))
#define IS_SINGLE_NUMBER(P) (IS_REAL_DOUBLE(P) && mxGetNumberOfElements(P) == 1)
#define IS_REAL_2D_FULL_DOUBLE(P) (!mxIsComplex(P) && \
        mxGetNumberOfDimensions(P) == 2 && !mxIsSparse(P) && mxIsDouble(P))
#define IS_REAL_SCALAR(P) (IS_REAL_2D_FULL_DOUBLE(P) && mxGetNumberOfElements(P) == 1)

void mexFunction(int nlhs, mxArray *phls[], int nrhs, const mxArray *prhs[]) {

    // Check the number of in- and output arguments
    if (nrhs < 4) {
        mexErrMsgTxt("You are missing some input arguments.");
    } else if (nrhs > 5) {
        mexErrMsgTxt("You have too many input arguments.");
    } else if (nlhs > 3) {
        mexErrMsgTxt("Too many output arguments.");
    }

    // Check if input arguments are in the right format
    if (!(IS_REAL_DOUBLE(prhs[0]) && MX_NUM_EL(prhs[0]) == 2)) {
        mexErrMsgTxt("First argument should be [x_start, y_start].");
    }
    if (!IS_SINGLE_NUMBER(prhs[1])) {
        mexErrMsgTxt("Second argument should be the starting angle in radians as a single number.");
    }
    if (!(IS_REAL_DOUBLE(prhs[2]) && MX_NUM_EL(prhs[2]) == 2)) {
        mexErrMsgTxt("Third argument should be [x_end, y_end].");
    }
    if (!(IS_REAL_DOUBLE(prhs[3]) && MX_NUM_EL(prhs[3]) == 4)) {
        mexErrMsgTxt("Fourth argument should be [field_x_min, field_x_max, field_y_min, field_y_max].");
    }
    if (!(IS_REAL_DOUBLE(prhs[3]) && MX_NUM_EL(prhs[3])%2 == 0 && mxGetNumberOfDimensions(prhs[3]) == 2)) {
        mexErrMsgTxt("Format of fifth argument should be [obst1_x, obst1_y; obst2_x, obst2_y; ...].");
    }

    printf("Format of input arguments checked\n\n");

    // Reset this, not sure if needed or not
    nodesChosen = 0, nodesLookedAt = 0, maxStepsTillNow = 0;

    // Setting the start and endpoint data from the input
    double *A = mxGetPr(prhs[0]);
    start_x = A[0];
    start_y = A[1];

    start_angle = mxGetScalar(prhs[1]);

    // End coordinate params
    A = mxGetPr(prhs[2]);
    end_x = A[0];
    end_y = A[1];

    printf("Start_x = %.2lf m, start_y = %.2lf m, start_angle = %.2lf rad\n", start_x, start_y, start_angle);
    printf("End_x = %.2lf m, end_y = %.2lf m\n", end_x, end_y);

    // Field size params
    A = mxGetPr(prhs[3]);
    field_x_min = A[0];
    field_x_max = A[1];
    field_y_min = A[2];
    field_y_max = A[3];

    printf("Field dimensions are [field_x_min = %.2lf, field_x_max = %.2lf, field_y_min = %.2lf, field_y_max = %.2lf]\n\n",
           field_x_min, field_x_max, field_y_min, field_y_max);

    // Only if the obstacles are set as an input argument, process them
    if (nrhs == 5) {
        // Put all the obstacles in a vector
        A = mxGetPr(prhs[4]);
        size_t M = mxGetM(prhs[4]); // Should be the number of obstacles
        //size_t N = mxGetN(prhs[4]); // Should be 2

        printf("Reading obstacles\n");

        // For some reason, MATLAB indexes in rows of a column and then wraps to the next column
        for (int m = 0; m < M; ++m) {
            Obstacle ob;
            ob.x = A[m];
            ob.y = A[m + M];
            obstacles.push_back(ob);

            printf("m = %d\n", m);
        }
    }

    // Set up angle array for the pathfinder to chose from
    angles = linSpace(-ANGLE_LIMIT, ANGLE_LIMIT, ANGLE_DIVISIONS);

    // Create start and end node
    start_node = new Node(NULL, start_x, start_y, 0);
    end_node = new Node(NULL, end_x, end_y, 0);

    // Set correct orientation of start and end node
    start_node->set_abs_angle(start_angle);
    start_node->estm_cost = costFunction(start_node);
    end_node->set_abs_angle(end_angle);

    printf("Start & end nodes and angle array created\n");

    PathNode *route = seekPath();
    // printRoute(route);

    if (route) {
        printf("Path successfully found\n");

        size_t nNodes;
        PathNode *path_list = backtrace(route, &nNodes);

        printf("Path traced from destination to start\n");

        phls[0] = mxCreateDoubleMatrix(1, nNodes, mxREAL);
        phls[1] = mxCreateDoubleMatrix(1, nNodes, mxREAL);
        phls[2] = mxCreateDoubleMatrix(1, nNodes, mxREAL);

        printf("Matrices created\n");

        double *x_mat = mxGetPr(phls[0]);
        double *y_mat = mxGetPr(phls[1]);
        double *ang_mat = mxGetPr(phls[2]);

        PathNode *ptr = path_list;

        printf("Filling matrices...\n");

        for (int i = 0; i < nNodes; ++i) {
            x_mat[i] = ptr->mapNode->x;
            y_mat[i] = ptr->mapNode->y;
            ang_mat[i] = ptr->mapNode->get_rel_angle();
            ptr = ptr->next;
        }
    } else {
        phls[0] = mxCreateDoubleMatrix(1, 1, mxREAL);
        phls[1] = mxCreateDoubleMatrix(1, 1, mxREAL);
        phls[2] = mxCreateDoubleMatrix(1, 1, mxREAL);

        double *x_mat = mxGetPr(phls[0]);
        double *y_mat = mxGetPr(phls[1]);
        double *ang_mat = mxGetPr(phls[2]);

        x_mat[0] = 0.0;
        y_mat[0] = 0.0;
        ang_mat[0] = 0.0;
    }

    cout << "End of program :'(" << endl;
}

#endif
