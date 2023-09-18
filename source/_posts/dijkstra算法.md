---
title: dijkstra算法
date: 2022-10-8 20:57:11
tags: [算法]
---
# dijkstra算法

Dijkstra 算法，用于对有权图进行搜索，找出图中两点的最短距离，既不是DFS搜索，也不是BFS搜索。把Dijkstra 算法应用于无权图，或者所有边的权都相等的图，Dijkstra 算法等同于BFS搜索。
dijkstra算法时间复杂度为$O(n^2)$


## 算法的思路：
设G=(V,E)是一个带权有向图，把图中顶点集合V分成两组第一组为已求出最短路径的顶点集合（用S表示，初始时S中只有一个源点，以后每求得一条最短路径,就将加入到集合S中，直到全部顶点都加入到S中，算法就结束了）第二组为其余未确定最短路径的顶点集合（用U表示），按最短路径长度的递增次序依次把第二组的顶点加入S中。在加入的过程中，总保持从源点v到S中各顶点的最短路径长度不大于从源点v到U中任何顶点的最短路径长度。此外，每个顶点对应一个距离，S中的顶点的距离就是从v到此顶点的最短路径长度，U中的顶点的距离，是从v到此顶点只包括S中的顶点为中间顶点的当前最短路径长度。

### 简单来说就是：
1. 先定义dist[1]=0,dist[i]=INF(0x3f);
2. for 1~n i判断不在S中，且距离最近的点，把他加入s中
3. 然后开始更新一下它到其他点的距离

```c++
int dijkstrac(){
    memset(dist,0x3f,sizeof dist);
    //初始化
    dist[1]=0;
    //设置A-->A=0开始距离

    for(int i=0;i<n;i++){
        int t=-1;
        for(int j=1;j<=n;j++)
        //寻找
        if(!st[j]&&(t==-1||dist[j]<dist[t]))
                t=j;
       st[t]=true;
       //最优路径
       for(int j=1;j<=n;j++)
       dist[j]=min(dist[j],dist[t]+g[t][j]);
    }
    if(dist[n]==0x3f3f3f3f)return -1;
    return dist[n];
}
```

## 例题
    acwing849 模板题

给定一个 n 个点 m条边的有向图，图中可能存在重边和自环，所有边权均为正值。
请你求出 1号点到 n 号点的最短距离，如果无法从 1 号点走到 n 号点，则输出 −1。

### 输入格式

第一行包含整数 n和 m。
接下来 m行每行包含三个整数 x,y,z，表示存在一条从点 x 到点 y 的有向边，边长为 z。

### 输出格式

输出一个整数，表示 1号点到 n号点的最短距离。如果路径不存在，则输出 −1。

### 数据范围

1≤n≤500,1≤m≤105,图中涉及边长均不超过10000。

### 输入样例：
    3 3
    1 2 2
    2 3 1
    1 3 4

### 输出样例：

    3

```C++
#include <bits/stdc++.h>
using namespace std;
#define MAX 1000
bool vis[MAX];
int dist[MAX],g[MAX][MAX];
int n,m;
int dijkstrac(int start){
    memset(dist,0x3f,sizeof dist);
    dist[start]=0;
    for(int i=0;i<n;i++){
        int t=-1;
        for(int j=1;j<=n;j++)
            //寻找
            if(!vis[j]&&(t==-1||dist[j]<dist[t]))
                t=j;

       vis[t]=true;
       //最优路径
       for(int j=1;j<=n;j++)
            dist[j]=min(dist[j],dist[t]+g[t][j]);
    }
    if(dist[n]==0x3f3f3f3f)return -1;
    return dist[n];
}

int main(){
    memset(g,0x3f,sizeof(g));
    cin>>n>>m;
    int u,v,dis;
    for(int i=0;i<m;i++){
        cin>>u>>v>>dis;
        g[u][v]=min(g[u][v],dis);
    }
    cout<<dijkstrac(1);
    return 0;
}
```

## 使用邻接链表

```c++
#include<bits/stdc++.h>
using namespace std;
#define MAX 300
#define INF 0x3f3f3f3f
int n,m,num_edge;
int dis[MAX],head[MAX];
bool vis[MAX];

struct Edge{
    int from,to,dis,next;
}edge[MAX];

void dijkstra(int start){
    memset(dis,0x3f,sizeof(dis));
    dis[start]=0;
    for(int i=0;i<n;i++){
        int u;
        int minn=INF;
        for(int j=1;j<=n;j++)
        if(!vis[j]&&dis[j]<minn){
                u=j;
                minn=dis[j];
        }
        vis[u]=true;
        for(int j=head[u];j!=0;j=edge[j].next)
            if(!vis[edge[j].to]&&(dis[u]+edge[j].dis<dis[edge[j].to]))
                dis[edge[j].to]=dis[u]+edge[j].dis;

    } 
}

void add(int from,int to,int dis){
	edge[++num_edge].next=head[from];
	edge[num_edge].from=from;
	edge[num_edge].to=to;
	edge[num_edge].dis=dis;
	head[from]=num_edge;
}

int main(){
    int u,v,w;
    cin>>n>>m;
	for(int i=1;i<=n;++i)  head[i]=-1;
	for(int i=1;i<=m;++i){
            cin>>u>>v>>w;
            add(u,v,w);
	}
	dijkstra(1);
	if(dis[n]==0x3f3f3f3f)cout<<-1<<endl;
	else cout<<dis[n];
    return 0;
}
```
## 使用邻接表+堆优化

```C++
#include<bits/stdc++.h> 
using namespace std;
int N,M,X;
const int MAX=100001;
int n,m;
bool vis[MAX];
int head[MAX],dis1[MAX],dis[MAX],num_edge;
struct Edge
{
    int from,to,next,dis;
}edge[MAX];

struct node{
	int id;
	int d;
	friend bool operator < (node a,node b){
		return a.d>b.d;
	}
};
priority_queue<node> q;

void add(int u,int v,int w){
    edge[++num_edge].next=head[u];
    edge[num_edge].from=u;
    edge[num_edge].to=v;
    edge[num_edge].dis=w;
    head[u]=num_edge;
}

void dijkstra(int start){
memset(vis,0,sizeof(vis)); 
    memset(dis,0x3f,sizeof(dis));//初始化距离数组 
    node st;
    st.id=start;st.d=dis[start]=0;//1点入队 
    q.push(st);
    while(!q.empty())
    {
    	node hh=q.top();
    	int u=hh.id;
    	q.pop();
    	if(vis[u]) continue;//若该点已经已知最短距离，访问过，则继续看下一个点
    	vis[u]=1;
    	for(int j=head[u];j!=0;j=edge[j].next){//松弛操作
    		int temp=edge[j].to;
    		if(!vis[temp]&&(dis[u]+edge[j].dis<dis[temp]))//更新，入队
       		{
        		dis[temp]=dis[u]+edge[j].dis;
        		node tt;
        		tt.id=temp;tt.d=dis[temp];
        		q.push(tt);
        	}
    	}        
    }
}

int main(){
    int u,v,w;
    cin>>n>>m;
	for(int i=1;i<=n;++i)  head[i]=-1;
	for(int i=1;i<=m;++i){
            cin>>u>>v>>w;
            add(u,v,w);
	}
	dijkstra(1);
	if(dis[n]==0x3f3f3f3f)cout<<-1<<endl;
	else cout<<dis[n];
    return 0;
}

```
