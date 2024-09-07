<?php
/*
*******************************************************************************************************************
* Warning!!!, Tidak untuk diperjual belikan!, Cukup pakai sendiri atau share kepada orang lain secara gratis
*******************************************************************************************************************
* Dibuat oleh @Maizil https://t.me/maizil41
*******************************************************************************************************************
* © 2024 Mutiara-Net By @Maizil
*******************************************************************************************************************
*/
?>
<?php
$sql = "SELECT username, pass, reply, authdate FROM radpostauth ORDER BY id DESC LIMIT 7";
$result = $conn->query($sql);

$user_data = [];
if ($result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        $user_data[] = [
            'username' => htmlspecialchars($row['username']),
            'reply' => htmlspecialchars($row['reply']),
            'authdate' => htmlspecialchars($row['authdate'])
        ];
    }
} else {
    $user_data[] = [
        'username' => '',
        'reply' => '',
        'authdate' => ''
    ];
}
?>
<tr>
    <th><center>Username</th>
    <th><center>Reply</th>
    <th><center>Auth Date</th>
</tr>
    </thead>
        <tbody>
            <?php foreach ($user_data as $user): ?>
                <td><center><?php echo $user['username']; ?></td>
                <td style="color: <?php echo ($user['reply'] == 'Access-Accept') ? 'green' : ($user['reply'] == 'Access-Reject' ? 'red' : 'black'); ?>">
                <center><?php echo $user['reply']; ?>
                </td>
                <td><center><?php echo $user['authdate']; ?></td>
                </tr>
            <?php endforeach; ?>
        </tbody>
    </table>
</div>
</main>

</body>
</html>
