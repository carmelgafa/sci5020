import numpy as np

def k_means(data, k=3, max_iters=100, tol=1e-4):
    # Initialize centroids randomly
    centroids = np.random.choice(data, k, replace=False)

    for _ in range(max_iters):
        # Assign each point to the nearest centroid
        clusters = {i: [] for i in range(k)}
        for item in data:
            closest_centroid = np.argmin([abs(item - c) for c in centroids])
            clusters[closest_centroid].append(item)

        # Compute new centroids
        new_centroids = np.array(
            [np.mean(cluster) for _, cluster in clusters.items()])
            # [np.mean(cluster) if cluster else centroids[i] for i, cluster in clusters.items()])

        # Check convergence
        if np.max(np.abs(new_centroids - centroids)) < tol:
            break

        centroids = new_centroids

    return centroids, clusters

# Example Usage
X = np.array([2, 5, 8, 1, 3, 7, 6, 4, 12, 14, 15, 20, 22, 25])  # Sample data
cent ,clust = k_means(X, k=3)

print("Clusters:")
for i, cluster in clust.items():
    print(f"Cluster {i+1}: {cluster}")

print("Centroids:", cent)
