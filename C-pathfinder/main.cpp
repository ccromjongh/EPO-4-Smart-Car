#include <iostream>
#include <vector>
#include <cmath>
#include <cstdlib>
#include <cstring>

using namespace std;
#define RADIUS 0.10
#define TWO_PI (2*M_PI)
#define END_TOLLERANCE 0.1

#define RADIUS_MULTIPLIER 100

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

const double start_x = 0.35, start_y = -0.12, start_angle = M_PI_2;
const double end_x = 2.39, end_y = 1.68, end_angle = -M_PI_4;
unsigned long nodesChosen = 0, nodesLookedAt = 0, maxStepsTillNow = 0;

Node *start_node, *end_node;

vector<double> angles;

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


vector<double> linSpace(double lower, double upper, double stepsize = 1) {
    unsigned int length = (unsigned int) (abs(upper - lower)/stepsize) + 1;
    vector<double> arr (length);

    for (int i = 0; i < length; ++i) {
        arr[i] = lower + i * stepsize;
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


unsigned int costFunction (Node *current) {
    unsigned int estm_cost = 0;
    unsigned int path_cost = (unsigned int) (RADIUS * RADIUS_MULTIPLIER * 0.95);

    // Add estimation cost for distance to the target
    double radius = calcRadius(current,  end_node);
    estm_cost += (radius * RADIUS_MULTIPLIER);

    // If we have a parent, add the cost of the steps already taken to the path length cost
    if (current->parent)
    {
        path_cost += current->parent->path_cost;
    }

    // Add some cost for the relative angle, because we don't want unnecessary steering
    path_cost += abs(current->get_rel_angle()) * 10;

    // Add some cost for the differential angle, because we want to change the steering direction as little as possible
    path_cost += abs(current->get_diff_angle()) * 20;

    // Estimation cost should include history of the path
    estm_cost += path_cost;

    // Set calculated properties
    current->estm_cost = estm_cost;
    current->path_cost = path_cost;

    // Return the estimation
    return estm_cost;
}

void seekPath() {
    PathNode *startPathNode, *openList, *working, *pathNodeOption;
    startPathNode = new PathNode(start_node);
    Node *nodeOption;

    openList = NULL;
    working = startPathNode;

    // Keep finding nodes, until we got sufficiently close to the end-node
    while (true)
    {
        for (int j = 0; j < 11; ++j) {
            double angle = angles[j] + working->mapNode->get_abs_angle();
            double _x = working->mapNode->x + RADIUS * cos(angle);
            double _y = working->mapNode->y + RADIUS * sin(angle);

            nodeOption = new Node(working->mapNode, _x, _y);
            pathNodeOption = new PathNode(nodeOption);
			nodesLookedAt++;

            /*if (calcRadius(nodeOption, end_node) <= END_TOLLERANCE) {
                goto reachedEnd;
            }*/
	
			placeSorted(&openList, pathNodeOption);
	
			if (openList && calcRadius(openList->mapNode, end_node) <= END_TOLLERANCE) {
                goto reachedEnd;
            }
        }

        if (openList == NULL)
        {
            cout << "No path could be found!" << endl;
            return;
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
        //x = working->mapNode->x;
        //y = working->mapNode->y;
    }

    reachedEnd: cout << "Found a path, yay!" << endl;
	
	printRoute(pathNodeOption);

    // Cleanup of all objects
    //deleteList(working);
    //deleteList(openList); //Not needed because of working = openList;
    //resetMap(false, false);
    //return cost;
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

    printf("\nMATLAB code:\n\nx = [%s];\ny = [%s];\nplot(x, y);\naxis([-2.5 2.5 -2.5 2.5]);\npbaspect([1 1 1]);\n\n", x_buffer, y_buffer);
}

int main() {
    angles = linSpace(-M_PI_4, M_PI_4, M_PI_4/5);
    start_node = new Node(NULL, start_x, start_y, 0);
    end_node = new Node(NULL, end_x, end_y, 0);

    start_node->set_abs_angle(start_angle);
    start_node->estm_cost = costFunction(start_node);


    seekPath();

    std::cout << "End of program :'(" << std::endl;
    return 0;
}

