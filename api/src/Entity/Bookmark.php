<?php

namespace App\Entity;

use ApiPlatform\Core\Annotation\ApiFilter;
use ApiPlatform\Core\Annotation\ApiResource;
use App\Repository\BookmarkRepository;
use Doctrine\ORM\Mapping as ORM;
use Symfony\Component\Serializer\Annotation\Groups;
use ApiPlatform\Core\Bridge\Doctrine\Orm\Filter\SearchFilter;
use App\Dto;

/**
 * @ApiResource(
 *     normalizationContext={"groups"={"read", "bookmark:read"}},
 *     denormalizationContext={"groups"={"write", "bookmark:write"}},
 *     itemOperations={
 *       "get"={
 *         "method"="GET",
 *         "security"="is_granted('ROLE_ADMIN') or (is_granted('ROLE_USER') and user == object.getUser())"
 *       },
 *       "delete"={
 *         "method"="DELETE",
 *         "security"="is_granted('ROLE_ADMIN') or (is_granted('ROLE_USER') and user == object.getUser())"
 *       }
 *     },
 *     collectionOperations={
 *       "get",
 *       "post"={
 *         "method"="POST",
 *         "input"=Dto\Input\Bookmark::class,
 *         "security"="is_granted('ROLE_USER')",
 *         "security_post_denormalize"="is_granted('ROLE_ADMIN') or (is_granted('ROLE_USER') and user == object.getUser())"
 *       }
 *     }
 * )
 * @ORM\Entity(repositoryClass=BookmarkRepository::class)
 * @ApiFilter(SearchFilter::class, properties={"user"})
 */
class Bookmark
{
    use Traits\TimestampTrait;

    /**
     * @ORM\Id
     * @ORM\GeneratedValue
     * @ORM\Column(type="integer")
     * @Groups("read")
     */
    private $id;

    /**
     * @var User
     * @ORM\ManyToOne(targetEntity="User")
     * @ORM\JoinColumn(nullable=false)
     * @Groups({"read", "bookmark:write"})
     */
    private $user;

    /**
     * @var UserVehicle
     * @ORM\ManyToOne(targetEntity="UserVehicle")
     * @Groups({"read", "bookmark:write"})
     */
    private $bookmarked_vehicle;

    /**
     * @var User
     * @ORM\ManyToOne(targetEntity="User")
     * @Groups({"read", "bookmark:write"})
     */
    private $bookmarked_user;

    /**
     * @var Job
     * @ORM\ManyToOne(targetEntity="Job")
     * @Groups({"read", "bookmark:write"})
     */
    private $bookmarked_job;

    public function getId(): ?int
    {
        return $this->id;
    }

    public function getUser(): User
    {
        return $this->user;
    }

    public function setUser(User $user): self
    {
        $this->user = $user;
        return $this;
    }

    public function getBookmarkedVehicle(): ?UserVehicle
    {
        return $this->bookmarked_vehicle;
    }

    public function setBookmarkedVehicle(?UserVehicle $bookmarked_vehicle): self
    {
        $this->bookmarked_vehicle = $bookmarked_vehicle;
        return $this;
    }

    public function getBookmarkedUser(): ?User
    {
        return $this->bookmarked_user;
    }

    public function setBookmarkedUser(?User $bookmarked_user): self
    {
        $this->bookmarked_user = $bookmarked_user;
        return $this;
    }

    public function getBookmarkedJob(): ?Job
    {
        return $this->bookmarked_job;
    }

    public function setBookmarkedJob(?Job $bookmarked_job): self
    {
        $this->bookmarked_job = $bookmarked_job;
        return $this;
    }


}
